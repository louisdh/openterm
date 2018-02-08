//
//  ios_system.m
//
//  Created by Nicolas Holzschuch on 17/11/2017.
//  Copyright © 2017 N. Holzschuch. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "ios_system.h"

// ios_system(cmd): Executes the command in "cmd". The goal is to be a drop-in replacement for system(), as much as possible.
// We assume cmd is the command. If vim has prepared '/bin/sh -c "(command -arguments) < inputfile > outputfile",
// it is easier to remove the "/bin/sh -c" part before calling ios_system than inside ios_system.
// See example in (iVim) os_unix.c
//
// ios_executable(cmd): returns true if the command is one of the commands defined in ios_system, and can be executed.
// This is because mch_can_exe (called by executable()) checks for the existence of binaries with the same name in the
// path. Our commands don't exist in the path.
//
// ios_popen(cmd, type): returns a FILE*, executes cmd, and thread_output into input of cmd (if type=="w") or
// the reverse (if type == "r").

#include <pthread.h>
#include <sys/stat.h>
#include <libgen.h> // for basename()
#include <dlfcn.h>  // for dlopen()/dlsym()/dlclose()
// is executable, looking at "x" bit. Other methods fails on iOS:
#define S_ISXXX(m) ((m) & (S_IXUSR | S_IXGRP | S_IXOTH))
// Sideloading: when you compile yourself, as opposed to uploading on the app store
// If defined, all functions are enabled. If undefined, you get a smaller set, but
// more compliance with AppStore rules.
// #define SIDELOADING

extern __thread int    __db_getopt_reset;
__thread FILE* thread_stdin;
__thread FILE* thread_stdout;
__thread FILE* thread_stderr;

typedef struct _functionParameters {
    int argc;
    char** argv;
    char** argv_ref;
    int (*function)(int ac, char** av);
    FILE *stdin, *stdout, *stderr;
    void* dlHandle;
    bool isPipe;
} functionParameters;

static void cleanup_function(void* parameters) {
    // This function is called when pthread_exit() is called
    functionParameters *p = (functionParameters *) parameters;
    fflush(thread_stdout);
    fflush(thread_stderr);
    // release parameters:
    for (int i = 0; i < p->argc; i++) free(p->argv_ref[i]);
    free(p->argv_ref);
    free(p->argv);
    if (p->isPipe) {
        // Close stdout if it won't be closed by another thread
        // (i.e. if it's different from the parent thread stdout)
        // There is currently no way to pipe stderr without piping stdout.
        // So close it only once.
        fclose(thread_stdout);
        thread_stdout = NULL;
    }
    if ((p->dlHandle != RTLD_SELF) && (p->dlHandle != RTLD_MAIN_ONLY)
        && (p->dlHandle != RTLD_DEFAULT) && (p->dlHandle != RTLD_NEXT))
        dlclose(p->dlHandle);
    free(parameters); // This was malloc'ed in ios_system
}

static void* run_function(void* parameters) {
    // re-initialize for getopt:
    // TODO: move to __thread variable for optind too
    
    optind = 1;
    opterr = 1;
    optreset = 1;
    __db_getopt_reset = 1;
    functionParameters *p = (functionParameters *) parameters;
    thread_stdin  = p->stdin;
    thread_stdout = p->stdout;
    thread_stderr = p->stderr;
    // Because some commands change argv, keep a local copy for release.
    p->argv_ref = (char **)malloc(sizeof(char*) * (p->argc + 1));
    for (int i = 0; i < p->argc; i++) p->argv_ref[i] = p->argv[i];
    pthread_cleanup_push(cleanup_function, parameters);
    p->function(p->argc, p->argv);
    pthread_cleanup_pop(1);
    return NULL;
}

static NSString* miniRoot = nil; // limit operations to below a certain directory (~, usually).
static NSDictionary *commandList = nil;
// do recompute directoriesInPath only if $PATH has changed
static NSString* fullCommandPath = @"";
static NSArray *directoriesInPath;
static NSString* previousDirectory;

void initializeEnvironment() {
    // setup a few useful environment variables
    // Initialize paths for application files, including history.txt and keys
    NSString *docsPath;
    if (miniRoot == nil) docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    else docsPath = miniRoot;
    previousDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
    
    // Where the executables are stored: $PATH + ~/Library/bin + ~/Documents/bin
    // Add content of old PATH to this. PATH *is* defined in iOS, surprising as it may be.
    // I'm not going to erase it, so we just add ourselves.
    // Sometimes, we go through main several times, so make sure we only append to PATH once
    NSString* checkingPath = [NSString stringWithCString:getenv("PATH") encoding:NSUTF8StringEncoding];
    if (! [fullCommandPath isEqualToString:checkingPath]) {
        fullCommandPath = checkingPath;
    }
    if (![fullCommandPath containsString:@"Documents/bin"]) {
        NSString *binPath = [docsPath stringByAppendingPathComponent:@"bin"];
        fullCommandPath = [[binPath stringByAppendingString:@":"] stringByAppendingString:fullCommandPath];
        setenv("PATH", fullCommandPath.UTF8String, 1); // 1 = override existing value
    }
    setenv("APPDIR", [[NSBundle mainBundle] resourcePath].UTF8String, 1);
    setenv("TERM", "xterm", 1); // 1 = override existing value
    setenv("TMPDIR", NSTemporaryDirectory().UTF8String, 0); // tmp directory
    
    // We can't write in $HOME so we need to set the position of config files:
    setenv("SSH_HOME", docsPath.UTF8String, 0);  // SSH keys in ~/Documents/.ssh/ or [Cloud Drive]/.ssh
    setenv("CURL_HOME", docsPath.UTF8String, 0); // CURL config in ~/Documents/ or [Cloud Drive]/
    setenv("SSL_CERT_FILE", [docsPath stringByAppendingPathComponent:@"cacert.pem"].UTF8String, 0); // SLL cacert.pem in ~/Documents/cacert.pem or [Cloud Drive]/cacert.pem
    // iOS already defines "HOME" as the home dir of the application
#ifdef SIDELOADING
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    if (![fullCommandPath containsString:@"Library/bin"]) {
        NSString *binPath = [libPath stringByAppendingPathComponent:@"bin"];
        fullCommandPath = [[binPath stringByAppendingString:@":"] stringByAppendingString:fullCommandPath];
    }
    // if we use Python, we define a few more environment variables:
    setenv("PYTHONHOME", libPath.UTF8String, 0);  // Python scripts in ~/Library/lib/python3.6/
    setenv("PYZMQ_BACKEND", "cffi", 0);
    setenv("JUPYTER_CONFIG_DIR", [docsPath stringByAppendingPathComponent:@".jupyter"].UTF8String, 0);
    // hg config file in ~/Documents/.hgrc
    setenv("HGRCPATH", [docsPath stringByAppendingPathComponent:@".hgrc"].UTF8String, 0);
#endif
    directoriesInPath = [fullCommandPath componentsSeparatedByString:@":"];
    setenv("PATH", fullCommandPath.UTF8String, 1); // 1 = override existing value
}

static char* parseArgument(char* argument, char* command) {
    // expand all environment variables, convert "~" to $HOME (only if localFile)
    // we also pass the shell command for some specific behaviour (don't do this for that command)
    NSString* argumentString = [NSString stringWithCString:argument encoding:NSUTF8StringEncoding];
    // 1) expand environment variables, + "~" (not wildcards ? and *)
    bool cannotExpand = false;
    while ([argumentString containsString:@"$"] && !cannotExpand) {
        // It has environment variables inside. Work on them one by one.
        // position of first "$" sign:
        NSRange r1 = [argumentString rangeOfString:@"$"];
        // position of first "/" after this $ sign:
        NSRange r2 = [argumentString rangeOfString:@"/" options:NULL range:NSMakeRange(r1.location + r1.length, [argumentString length] - r1.location - r1.length)];
        // position of first ":" after this $ sign:
        NSRange r3 = [argumentString rangeOfString:@":" options:NULL range:NSMakeRange(r1.location + r1.length, [argumentString length] - r1.location - r1.length)];
        if ((r2.location == NSNotFound) && (r3.location == NSNotFound)) r2.location = [argumentString length];
        else if ((r2.location == NSNotFound) || (r3.location < r2.location)) r2.location = r3.location;
        
        NSRange  rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
        NSString *variable_string = [argumentString substringWithRange:rSub];
        const char* variable = getenv([variable_string UTF8String]);
        if (variable) {
            // Okay, so this one exists.
            NSString* replacement_string = [NSString stringWithCString:variable encoding:NSUTF8StringEncoding];
            variable_string = [[NSString stringWithCString:"$" encoding:NSUTF8StringEncoding] stringByAppendingString:variable_string];
            argumentString = [argumentString stringByReplacingOccurrencesOfString:variable_string withString:replacement_string];
        } else cannotExpand = true; // found a variable we can't expand. stop trying for this argument
    }
    // 2) Tilde conversion: replace "~" with $HOME
    // If there are multiple users on iOS, this code will need to be changed.
    if([argumentString hasPrefix:@"~"]) {
        // So it begins with "~".
        if (miniRoot == nil) argumentString = [argumentString stringByExpandingTildeInPath]; // replaces "~", "~/"
        if ((miniRoot != nil) || ([argumentString hasPrefix:@"~:"])) { // not done by stringByExpandingTildeInPath
            NSString* test_string = @"~";
            NSString* replacement_string;
            if (miniRoot == nil)
                replacement_string = [NSString stringWithCString:(getenv("HOME")) encoding:NSUTF8StringEncoding];
            else replacement_string = miniRoot;
            argumentString = [argumentString stringByReplacingOccurrencesOfString:test_string withString:replacement_string options:NULL range:NSMakeRange(0, 1)];
        }
    }
    // Also convert ":~something" in PATH style variables
    // We don't use these yet, but we could.
    // We do this expansion only for setenv
    if (strcmp(command, "setenv") == 0) {
        // This is something we need to avoid if the command is "scp" or "sftp"
        if ([argumentString containsString:@":~"]) {
            NSString* homeDir;
            if (miniRoot == nil) homeDir = [NSString stringWithCString:(getenv("HOME")) encoding:NSUTF8StringEncoding];
            else homeDir = miniRoot;
            // Only 1 possibility: ":~" (same as $HOME)
            if (homeDir.length > 0) {
                if ([argumentString containsString:@":~/"]) {
                    NSString* test_string = @":~/";
                    NSString* replacement_string = [[NSString stringWithCString:":" encoding:NSUTF8StringEncoding] stringByAppendingString:homeDir];
                    replacement_string = [replacement_string stringByAppendingString:[NSString stringWithCString:"/" encoding:NSUTF8StringEncoding]];
                    argumentString = [argumentString stringByReplacingOccurrencesOfString:test_string withString:replacement_string];
                } else if ([argumentString hasSuffix:@":~"]) {
                    NSString* test_string = @":~";
                    NSString* replacement_string = [[NSString stringWithCString:":" encoding:NSUTF8StringEncoding] stringByAppendingString:homeDir];
                    argumentString = [argumentString stringByReplacingOccurrencesOfString:test_string withString:replacement_string options:NULL range:NSMakeRange([argumentString length] - 2, 2)];
                } else if ([argumentString hasSuffix:@":"]) {
                    NSString* test_string = @":";
                    NSString* replacement_string = [[NSString stringWithCString:":" encoding:NSUTF8StringEncoding] stringByAppendingString:homeDir];
                    argumentString = [argumentString stringByReplacingOccurrencesOfString:test_string withString:replacement_string options:NULL range:NSMakeRange([argumentString length] - 2, 2)];
                }
            }
        }
    }
    char* newArgument = [argumentString UTF8String];
    if (strcmp(argument, newArgument) == 0) return argument; // nothing changed
    // Make sure the argument is reallocated, so it can be free-ed
    char* returnValue = realloc(argument, strlen(newArgument));
    strcpy(returnValue, newArgument);
    return returnValue;
}


static void initializeCommandList()
{
    // 1st component: name of digital library
    // 2nd component: name of command
    // 3rd component: chain sent to getopt (for arguments in autocomplete)
    // 4th component: takes a file/directory as argument
    if (commandList != nil) return;
    commandList = \
    @{
      // libfiles.dylib
      @"ls"    : [NSArray arrayWithObjects: @"libfiles.dylib", @"ls_main", @"1@ABCFGHLOPRSTUWabcdefghiklmnopqrstuvwx", @"file", nil],
      @"touch" : [NSArray arrayWithObjects:@"libfiles.dylib", @"touch_main", @"A:acfhmr:t:", @"file", nil],
      @"rm"    : [NSArray arrayWithObjects:@"libfiles.dylib", @"rm_main", @"dfiPRrvW", @"file", nil],
      @"unlink": [NSArray arrayWithObjects:@"libfiles.dylib", @"rm_main", @"", @"file", nil],
      @"cp"    : [NSArray arrayWithObjects:@"libfiles.dylib", @"cp_main", @"cHLPRXafinprv",  @"file", nil],
      @"ln"    : [NSArray arrayWithObjects:@"libfiles.dylib", @"ln_main", @"Ffhinsv", @"file", nil],
      @"link"  : [NSArray arrayWithObjects:@"libfiles.dylib", @"ln_main", @"", @"file", nil],
      @"mv"    : [NSArray arrayWithObjects:@"libfiles.dylib", @"mv_main", @"finv", @"file", nil],
      @"mkdir" : [NSArray arrayWithObjects:@"libfiles.dylib", @"mkdir_main", @"m:pv", @"directory", nil],
      @"rmdir" : [NSArray arrayWithObjects:@"libfiles.dylib", @"rmdir_main", @"p", @"directory", nil],
      @"chflags": [NSArray arrayWithObjects:@"libfiles.dylib", @"chflags_main", @"HLPRfhv", @"file", nil],
#ifdef SIDELOADING
      // Exposes the outside of the sandbox a little too much. YMMV
      @"chown" : [NSArray arrayWithObjects:@"libfiles.dylib", @"chown_main", @"HLPRfhv", @"file", nil],
      @"chgrp" : [NSArray arrayWithObjects:@"libfiles.dylib", @"chown_main", @"HLPRfhv", @"file", nil],
      @"chmod" : [NSArray arrayWithObjects:@"libfiles.dylib", @"chmod_main", @"ACEHILNPRVXafghinorstuvwx", @"file", nil],
      @"df"    : [NSArray arrayWithObjects:@"libfiles.dylib", @"df_main", @"abgHhiklmnPtT:", @"file", nil],
#endif
      @"du"    : [NSArray arrayWithObjects:@"libfiles.dylib", @"du_main", @"HI:LPasd:cghkmrx", @"no", nil],
      @"chksum" : [NSArray arrayWithObjects:@"libfiles.dylib", @"chksum_main", @"o:", @"file", nil],
      @"sum"    : [NSArray arrayWithObjects:@"libfiles.dylib", @"chksum_main", @"", @"file", nil],
      @"stat"   : [NSArray arrayWithObjects:@"libfiles.dylib", @"stat_main", @"f:FlLnqrst:x", @"file", nil],
      @"readlink": [NSArray arrayWithObjects:@"libfiles.dylib", @"stat_main", @"n", @"file", nil],
      @"compress": [NSArray arrayWithObjects:@"libfiles.dylib", @"compress_main", @"b:cdfv", @"file", nil],
      @"uncompress": [NSArray arrayWithObjects:@"libfiles.dylib", @"compress_main", @"b:cdfv", @"file", nil],
      @"gzip"   : [NSArray arrayWithObjects:@"libfiles.dylib", @"gzip_main", @"123456789acdfhklLNnqrS:tVv", @"file", nil],
      @"gunzip" : [NSArray arrayWithObjects:@"libfiles.dylib", @"gzip_main", @"123456789acdfhklLNnqrS:tVv", @"file", nil],
      // libtar.dylib
      @"tar"    : [NSArray arrayWithObjects:@"libtar.dylib", @"tar_main", @"Bb:C:cf:HhI:JjkLlmnOoPpqrSs:T:tUuvW:wX:xyZz", @"file", nil],
      // libcurl.dylib
      // From curl. curl with ssh requires keys, and thus keys generation / management.
      // We assume you moved over the keys, known_host files from elsewhere
      // http, https, ftp... should be OK.
      @"curl"    : [NSArray arrayWithObjects:@"libcurl.dylib", @"curl_main", @"2346aAbBcCdDeEfgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwxXYyz#", @"file", nil],
      // scp / sftp require conversion to curl, rewriting arguments
      @"scp"     : [NSArray arrayWithObjects:@"libcurl.dylib", @"curl_main", @"q", @"file", nil],
      @"sftp"    : [NSArray arrayWithObjects:@"libcurl.dylib", @"curl_main", @"q", @"file", nil],
      @"ssh"     : [NSArray arrayWithObjects:@"libssh_cmd.dylib", @"ssh_main", @"q", @"file", nil],
      // local commands. Either self (here) or main (main program)
      @"cd"      : [NSArray arrayWithObjects:@"SELF", @"cd_main", @"", @"directory", nil],
      // Commands from Apple shell_cmds:
      @"echo"   : [NSArray arrayWithObjects:@"libshell.dylib", @"echo_main", @"n", @"no", nil],
      @"printenv": [NSArray arrayWithObjects:@"libshell.dylib", @"printenv_main", @"", @"no", nil],
      @"pwd"    : [NSArray arrayWithObjects:@"libshell.dylib", @"pwd_main", @"LP", @"no", nil],
      @"tee"    : [NSArray arrayWithObjects:@"libshell.dylib", @"tee_main", @"ai", @"file", nil],
      @"uname"  : [NSArray arrayWithObjects:@"libshell.dylib", @"uname_main", @"amnprsv", @"no", nil],
      @"date"   : [NSArray arrayWithObjects:@"libshell.dylib", @"date_main", @"d:f:jnRr:t:uv:", @"no", nil],
      @"env"    : [NSArray arrayWithObjects:@"libshell.dylib", @"env_main", @"-iP:S:u:v", @"no", nil],
      @"setenv"     : [NSArray arrayWithObjects:@"libshell.dylib", @"setenv_main", @"", @"no", nil],
      @"unsetenv"     : [NSArray arrayWithObjects:@"libshell.dylib", @"unsetenv_main", @"", @"no", nil],
      @"whoami" : [NSArray arrayWithObjects:@"libshell.dylib", @"id_main", @"", @"no", nil],
      @"uptime" : [NSArray arrayWithObjects:@"libshell.dylib", @"w_main", @"", @"no", nil],
#ifdef SIDELOADING
      // Exposes the outside of the sandbox a little too much. YMMV
      @"id"     : [NSArray arrayWithObjects:@"libshell.dylib", @"id_main", @"AFPGMagnpru", @"no", nil],
      @"groups" : [NSArray arrayWithObjects:@"libshell.dylib", @"id_main", @"", @"no", nil],
      @"w"      : [NSArray arrayWithObjects:@"libshell.dylib", @"w_main", @"dhiflM:N:nsuw", @"no", nil],
#endif
      // Commands from Apple text_cmds:
      @"cat"    : [NSArray arrayWithObjects:@"libtext.dylib", @"cat_main", @"benstuv", @"file", nil],
      @"wc"     : [NSArray arrayWithObjects:@"libtext.dylib", @"wc_main", @"dhiflM:N:nsuw", @"file", nil],
      @"tr"     : [NSArray arrayWithObjects:@"libtext.dylib", @"tr_main", @"Ccdsu", @"no", nil],
      // compiled, but deactivated until we have interactive mode
      // @"ed"     : [NSArray arrayWithObjects:@"libtext.dylib", @"w_main", @"p:sx", @"file", nil][NSValue valueWithPointer: ed_main],
      // @"red"     : [NSArray arrayWithObjects:@"libtext.dylib", @"w_main", @"p:sx", @"file", nil][NSValue valueWithPointer: ed_main],
      @"sed"     : [NSArray arrayWithObjects:@"libtext.dylib", @"sed_main", @"Eae:f:i:ln", @"file", nil],
      @"awk"     : [NSArray arrayWithObjects:@"libtext.dylib", @"awk_main", @"dhiflM:N:nsuw", @"file", nil],
      @"grep"   : [NSArray arrayWithObjects:@"libtext.dylib", @"grep_main", @"0123456789A:B:C:D:EFGHIJMLOPSRUVZabcd:e:f:hilm:nopqrsuvwxXy", @"file", nil],
      @"egrep"  : [NSArray arrayWithObjects:@"libtext.dylib", @"grep_main", @"0123456789A:B:C:D:EFGHIJMLOPSRUVZabcd:e:f:hilm:nopqrsuvwxXy", @"file", nil],
      @"fgrep"  : [NSArray arrayWithObjects:@"libtext.dylib", @"grep_main", @"0123456789A:B:C:D:EFGHIJMLOPSRUVZabcd:e:f:hilm:nopqrsuvwxXy", @"file", nil],
#ifdef SIDELOADING
      // Scripts and programming languages. Might move outside of here at some point
      // lua
      @"lua"     : [NSArray arrayWithObjects:@"lua_ios.framework/lua_ios", @"lua_main", @"e:il:vE", @"file", nil],
      @"luac"    : [NSArray arrayWithObjects:@"lua_ios.framework/lua_ios", @"luac_main", @"lpsvo:", @"file", nil],
      // from python:
      @"python"  : [NSArray arrayWithObjects:@"Python_ios.framework/Python_ios", @"python_main", @"3bBc:dEhiJm:OQ:RsStuUvVW:xX?", @"file", nil],
      // TeX
      // LuaTeX:
      @"luatex"     : [NSArray arrayWithObjects:@"libluatex.dylib", @"dllluatexmain", @"", @"file", nil],
      @"lualatex"     : [NSArray arrayWithObjects:@"libluatex.dylib", @"dllluatexmain", @"", @"file", nil],
      @"texlua"     : [NSArray arrayWithObjects:@"libluatex.dylib", @"dllluatexmain", @"", @"file", nil],
      @"texluac"     : [NSArray arrayWithObjects:@"libluatex.dylib", @"dllluatexmain", @"", @"file", nil],
      @"dviluatex"     : [NSArray arrayWithObjects:@"libluatex.dylib", @"dllluatexmain", @"", @"file", nil],
      @"dvilualatex"     : [NSArray arrayWithObjects:@"libluatex.dylib", @"dllluatexmain", @"", @"file", nil],
      // pdfTeX
      @"amstex"     :  [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"cslatex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"csplain"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"eplain"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"etex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"jadetex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"latex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"mex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"mllatex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"mltex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"pdfcslatex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"pdfcsplain"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"pdfetex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"pdfjadetex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"pdflatex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"pdftex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"pdfmex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"pdfxmltex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"texsis"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"utf8mex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      @"xmltex"     : [NSArray arrayWithObjects:@"libpdftex.dylib", @"dllpdftexmain", @"", @"file", nil],
      // BibTeX
      @"bibtex"     : [NSArray arrayWithObjects:@"libbibtex.dylib", @"bibtex_main", @"", @"file", nil],
#endif
    };
}

int ios_setMiniRoot(NSString* mRoot) {
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:mRoot isDirectory:&isDir]) {
        if (isDir) {
            // fileManager has different ways of expressing the same directory.
            // We need to actually change to the directory to get its "real name".
            NSString* currentDir = [[NSFileManager defaultManager] currentDirectoryPath];
            if ([[NSFileManager defaultManager] changeCurrentDirectoryPath:mRoot]) {
                // also don't set the miniRoot if we can't go in there
                // get the real name for miniRoot:
                miniRoot = [[NSFileManager defaultManager] currentDirectoryPath];
                // Back to where we we before:
                [[NSFileManager defaultManager] changeCurrentDirectoryPath:currentDir];
                return 1; // mission accomplished
            }
        }
    }
    return 0;
}

int cd_main(int argc, char** argv) {
    NSString* currentDir = [[NSFileManager defaultManager] currentDirectoryPath];
    if (argc > 1) {
        NSString* newDir = @(argv[1]);
        if (strcmp(argv[1], "-") == 0) {
            // "cd -" option to pop back to previous directory
            newDir = previousDirectory;
        }
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:newDir isDirectory:&isDir]) {
            if (isDir) {
                if ([[NSFileManager defaultManager] changeCurrentDirectoryPath:newDir]) {
                    // We managed to change the directory.
                    // Was that allowed?
                    NSString* resultDir = [[NSFileManager defaultManager] currentDirectoryPath];
                    if ((miniRoot != nil) && (![resultDir hasPrefix:miniRoot])) {
                        fprintf(thread_stderr, "cd: %s: permission denied\n", [newDir UTF8String]);
                        [[NSFileManager defaultManager] changeCurrentDirectoryPath:miniRoot];
                        currentDir = miniRoot;
                    }
                    previousDirectory = currentDir;
                } else fprintf(thread_stderr, "cd: %s: permission denied\n", [newDir UTF8String]);
            }
            else  fprintf(thread_stderr, "cd: %s: not a directory\n", [newDir UTF8String]);
        } else {
            fprintf(thread_stderr, "cd: %s: no such file or directory\n", [newDir UTF8String]);
        }
    } else { // [cd] Help, I'm lost, bring me back home
        previousDirectory = [[NSFileManager defaultManager] currentDirectoryPath];

        if (miniRoot != nil) {
            [[NSFileManager defaultManager] changeCurrentDirectoryPath:miniRoot];
        } else {
            [[NSFileManager defaultManager] changeCurrentDirectoryPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        }
    }
    return 0;
}


NSString* getoptString(NSString* commandName) {
    if (commandList == nil) initializeCommandList();
    NSArray* commandStructure = [commandList objectForKey: commandName];
    if (commandStructure != nil) return commandStructure[2];
    else return @"";
}

NSString* operatesOn(NSString* commandName) {
    if (commandList == nil) initializeCommandList();
    NSArray* commandStructure = [commandList objectForKey: commandName];
    if (commandStructure != nil) return commandStructure[3];
    else return @"";
}


int ios_executable(const char* inputCmd) {
    // returns 1 if this is one of the commands we define in ios_system, 0 otherwise
    if (commandList == nil) initializeCommandList();
    NSArray* valuesFromDict = [commandList objectForKey: [NSString stringWithCString:inputCmd]];
    // we could dlopen() here, but that would defeat the purpose
    if (valuesFromDict == nil) return 0;
    else return 1;
}

// Where to direct input/output of the next thread:
static __thread FILE* child_stdin;
static __thread FILE* child_stdout;
static __thread FILE* child_stderr;

FILE* ios_popen(const char* inputCmd, const char* type) {
    // Save existing streams:
    int fd[2] = {0};
    const char* command = inputCmd;
    // skip past all spaces
    while ((command[0] == ' ') && strlen(command) > 0) command++;
    // TODO: skip past "/bin/sh -c" and "sh -c"
    if (pipe(fd) < 0) { return NULL; } // Nothing we can do if pipe fails
    // NOTES: fd[0] is set up for reading, fd[1] is set up for writing
    // fpout = fdopen(fd[1], "w");
    // fpin = fdopen(fd[0], "r");
    if (type[0] == 'w') {
        // open pipe for reading
        child_stdin = fdopen(fd[0], "r");
        // launch command:
        ios_system(command);
        return fdopen(fd[1], "w");
    } else if (type[0] == 'r') {
        // open pipe for writing
        // set up streams for thread
        child_stdout = fdopen(fd[1], "w");
        // launch command:
        ios_system(command);
        return fdopen(fd[0], "r");
    }
    return NULL;
}

int ios_execv(const char *path, char* const argv[]) {
    // path and argv[0] are the same (not in theory, but in practice, since Python wrote the command)
    int argc = 0;
    int cmdLength = 0;
    // concatenate all arguments into a big command.
    // We need this because some programs call execv() with a single string: "ssh hg@bitbucket.org 'hg -R ... --stdio'"
    // So we rely on ios_system to break them into chunks.
    while(argv[argc] != NULL) { cmdLength += strlen(argv[argc]) + 1; argc++;}
    char* cmd = malloc((cmdLength  + 2 * argc) * sizeof(char)); // space for quotes
    strcpy(cmd, argv[0]);
    argc = 1;
    while (argv[argc] != NULL) {
        if (strstr(argv[argc], " ")) {
            // argument contains spaces. Enclose it into quotes:
            if (strstr(argv[argc], "\"") == NULL) {
                // argument does not contain ". Enclose with "
                strcat(cmd, " \"");
                strcat(cmd, argv[argc]);
                strcat(cmd, "\"");
                argc++;
                continue;
            }
            if (strstr(argv[argc], "'") == NULL) {
                // Enclose with '
                strcat(cmd, " '");
                strcat(cmd, argv[argc]);
                strcat(cmd, "'");
                argc++;
                continue;
            }
            fprintf(thread_stderr, "Don't know what to do with this argument, sorry: %s\n", argv[argc]);
        }
        strcat(cmd, " ");
        strcat(cmd, argv[argc]);
        argc++;
    }
    // start "child" with the child streams:
    ios_system(cmd);
    free(cmd);
    return 0;
}

int ios_execve(const char *path, char* const argv[], char *const envp[]) {
    // TODO: save the environment (HOW?) and current dir
    // TODO: replace environment with envp. envp looks a lot like current environment, though.
    ios_execv(path, argv);
    // TODO: restore the environment (HOW?)
    return 0;
}

/*
 * Public domain dup2() lookalike
 * by Curtis Jackson @ AT&T Technologies, Burlington, NC
 * electronic address:  burl!rcj
 * Edited for iOS by N. Holzschuch.
 * The idea is that dup2(fd, [012]) is usually called between fork and exec.
 *
 * dup2 performs the following functions:
 *
 * Check to make sure that fd1 is a valid open file descriptor.
 * Check to see if fd2 is already open; if so, close it.
 * Duplicate fd1 onto fd2; checking to make sure fd2 is a valid fd.
 * Return fd2 if all went well; return BADEXIT otherwise.
 */

int ios_dup2(int fd1, int fd2)
{
    // iOS specifics: trying to access stdin/stdout/stderr?
    // fprintf(stderr, "Accessing dup2: fd1 = %d fd2 = %d\n", fd1, fd2); fflush(stderr);
    if (fd2 == 0) { child_stdin = fdopen(fd1, "rb"); }
    else if (fd2 == 1) { child_stdout = fdopen(fd1, "wb"); }
    else if (fd2 == 2) { child_stderr = fdopen(fd1, "wb"); }
    else if (fd1 != fd2) {
        if (fcntl(fd1, F_GETFL) < 0)
            return -1;
        if (fcntl(fd2, F_GETFL) >= 0)
            close(fd2);
        if (fcntl(fd1, F_DUPFD, fd2) < 0)
            return -1;
    }
    return fd2;
}



// For customization:
// replaces a function  (e.g. ls_main) with another one, provided by the user (ls_mine_main)
// if the function does not exist, add it to the list
// if "allOccurences" is true, search for all commands that share the same function, replace them too.
// ("compress" and "uncompress" both point to compress_main. You probably want to replace both, but maybe
// you just happen to have a very fast uncompress, different from compress).
// We work with function names, not function pointers.
void replaceCommand(NSString* commandName, NSString* functionName, bool allOccurences) {
    if (commandList == nil) initializeCommandList();
    NSArray* oldValues = [commandList objectForKey: commandName];
    NSString* oldFunctionName = nil;
    if (oldValues != nil) oldFunctionName = oldValues[1];
    NSMutableDictionary *mutableDict = [commandList mutableCopy];
    mutableDict[commandName] = [NSArray arrayWithObjects: @"MAIN", functionName, @"", @"file", nil];
    
    if ((oldFunctionName != nil) && allOccurences) {
        // scan through all dictionary entries
        for (NSString* existingCommand in mutableDict.allKeys) {
            NSArray* currentPosition = [mutableDict objectForKey: existingCommand];
            if ([currentPosition[1] isEqualToString:oldFunctionName])
                [mutableDict setValue: [NSArray arrayWithObjects: @"MAIN", functionName, @"", @"file", nil] forKey: existingCommand];
        }
    }
    commandList = [mutableDict mutableCopy];
}

NSString* commandsAsString() {
    
    if (commandList == nil) initializeCommandList();
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:commandList.allKeys options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return myString;
}

NSArray* commandsAsArray() {
    if (commandList == nil) initializeCommandList();
    return commandList.allKeys;
}

int ios_system(const char* inputCmd) {
    char* command;
    // The names of the files for stdin, stdout, stderr
    char* inputFileName = 0;
    char* outputFileName = 0;
    char* errorFileName = 0;
    // Where the symbols "<", ">" or "2>" were.
    // to be replaced by 0x0 later.
    char* outputFileMarker = 0;
    char* inputFileMarker = 0;
    char* errorFileMarker = 0;
    char* scriptName = 0; // interpreted commands
    bool  sharedErrorOutput = false;
    static bool isMainThread = true;
    static pthread_t lastThreadId = 0; // last command on the command line (with pipes)
    
    // initialize:
    if (thread_stdin == 0) thread_stdin = stdin;
    if (thread_stdout == 0) thread_stdout = stdout;
    if (thread_stderr == 0) thread_stderr = stderr;
    
    char* cmd = strdup(inputCmd);
    char* maxPointer = cmd + strlen(cmd);
    char* originalCommand = cmd;
    // fprintf(thread_stderr, "Command sent: %s \n", cmd); fflush(stderr);
    if (cmd[0] == '"') {
        // Command was enclosed in quotes (almost always with Vim)
        char* endCmd = strstr(cmd + 1, "\""); // find closing quote
        if (endCmd) {
            cmd = cmd + 1; // remove starting quote
            endCmd[0] = 0x0;
            assert(endCmd < maxPointer);
        }
        // assert(cmd + strlen(cmd) < maxPointer);
    }
    if (cmd[0] == '(') {
        // Standard vim encoding: command between parentheses
        command = cmd + 1;
        char* endCmd = strstr(command, ")"); // remove closing parenthesis
        if (endCmd) {
            endCmd[0] = 0x0;
            assert(endCmd < maxPointer);
            inputFileMarker = endCmd + 1;
        }
    } else command = cmd;
    // fprintf(thread_stderr, "Command sent: %s \n", command);
    // Search for input, output and error redirection
    // They can be in any order, although the usual are:
    // command < input > output 2> error, command < input > output 2>&1 or command < input >& output
    // The last two are equivalent. Vim prefers the second.
    // Search for input file "< " and output file " >"
    if (!inputFileMarker) inputFileMarker = command;
    outputFileMarker = inputFileMarker;
    functionParameters *params = (functionParameters*) malloc(sizeof(functionParameters));
    // If child_streams have been defined (in dup2 or popen), the new thread takes them.
    params->stdin = child_stdin;
    params->stdout = child_stdout;
    params->stderr = child_stderr;
    child_stdin = child_stdout = child_stderr = NULL;
    params->argc = 0; params->argv = 0; params->argv_ref = 0;
    params->function = NULL; params->isPipe = false;
    // scan until first "<" (input file)
    inputFileMarker = strstr(inputFileMarker, "<");
    // scan until first non-space character:
    if (inputFileMarker) {
        inputFileName = inputFileMarker + 1; // skip past '<'
        // skip past all spaces
        while ((inputFileName[0] == ' ') && strlen(inputFileName) > 0) inputFileName++;
    }
    // is there a pipe ("|", "&|" or "|&")
    // We assume here a logical command order: < before pipe, pipe before >.
    // TODO: check what happens for unlogical commands. Refuse them, but gently.
    // TODO: implement tee, because that has been removed
    char* pipeMarker = strstr (outputFileMarker,"&|");
    if (!pipeMarker) pipeMarker = strstr (outputFileMarker,"|&"); // both seem to work
    if (pipeMarker) {
        bool pushMainThread = isMainThread;
        isMainThread = false;
        params->stdout = ios_popen(pipeMarker+2, "w");
        isMainThread = pushMainThread;
        pipeMarker[0] = 0x0;
        sharedErrorOutput = true;
    } else {
        pipeMarker = strstr (outputFileMarker,"|");
        if (pipeMarker) {
            bool pushMainThread = isMainThread;
            isMainThread = false;
            params->stdout = ios_popen(pipeMarker+1, "w");
            isMainThread = pushMainThread;
            pipeMarker[0] = 0x0;
        }
    }
    // We have removed the pipe part. Still need to parse the rest of the command
    // Must scan in strstr by reverse order of inclusion. So "2>&1" before "2>" before ">"
    if (params->stdout == 0) {
        errorFileMarker = strstr (outputFileMarker,"&>"); // both stderr/stdout sent to same file
        // output file name will be after "&>"
        if (errorFileMarker) { outputFileName = errorFileMarker + 2; outputFileMarker = errorFileMarker; }
    }
    if (!errorFileMarker && (params->stderr == 0)) {
        // TODO: 2>&1 before > means redirect stderr to (current) stdout, then redirects stdout
        // ...except with a pipe.
        // Currently, we don't check for that.
        errorFileMarker = strstr (outputFileMarker,"2>&1"); // both stderr/stdout sent to same file
        if (errorFileMarker) {
            if (params->stdout) params->stderr = params->stdout;
            else {
                outputFileMarker = strstr(outputFileMarker, ">");
                if (outputFileMarker) outputFileName = outputFileMarker + 1; // skip past '>'
            }
        }
    }
    if (errorFileMarker) { sharedErrorOutput = true; }
    else if (params->stderr == 0) {
        // specific name for error file?
        errorFileMarker = strstr(outputFileMarker,"2>");
        if (errorFileMarker) {
            errorFileName = errorFileMarker + 2; // skip past "2>"
            // skip past all spaces:
            while ((errorFileName[0] == ' ') && strlen(errorFileName) > 0) errorFileName++;
        }
    }
    // scan until first ">"
    if (!sharedErrorOutput && (params->stdout == 0)) {
        outputFileMarker = strstr(outputFileMarker, ">");
        if (outputFileMarker) outputFileName = outputFileMarker + 1; // skip past '>'
    }
    if (outputFileName) {
        while ((outputFileName[0] == ' ') && strlen(outputFileName) > 0) outputFileName++;
    }
    if (errorFileName && (outputFileName == errorFileName)) {
        // we got the same ">" twice, pick the next one ("2>" was before ">")
        outputFileMarker = errorFileName;
        outputFileMarker = strstr(outputFileMarker, ">");
        if (outputFileMarker) {
            outputFileName = outputFileMarker + 1; // skip past '>'
            while ((outputFileName[0] == ' ') && strlen(outputFileName) > 0) outputFileName++;
        } else outputFileName = NULL; // Only "2>", but no ">". It happens.
    }
    if (outputFileName) {
        char* endFile = strstr(outputFileName, " ");
        if (endFile) endFile[0] = 0x00; // end output file name at first space
        assert(endFile < maxPointer);
    }
    if (inputFileName) {
        char* endFile = strstr(inputFileName, " ");
        if (endFile) endFile[0] = 0x00; // end input file name at first space
        assert(endFile < maxPointer);
    }
    if (errorFileName) {
        char* endFile = strstr(errorFileName, " ");
        if (endFile) endFile[0] = 0x00; // end error file name at first space
        assert(endFile < maxPointer);
    }
    // insert chain termination elements at the beginning of each filename.
    // Must be done after the parsing
    if (inputFileMarker) inputFileMarker[0] = 0x0;
    if (outputFileMarker && (params->stdout == NULL)) outputFileMarker[0] = 0x0;
    if (errorFileMarker) errorFileMarker[0] = 0x0;
    // strip filenames of quotes, if any:
    if (outputFileName && (outputFileName[0] == '\'')) { outputFileName = outputFileName + 1; outputFileName[strlen(outputFileName) - 1] = 0x0; }
    if (inputFileName && (inputFileName[0] == '\'')) { inputFileName = inputFileName + 1; inputFileName[strlen(inputFileName) - 1] = 0x0; }
    if (errorFileName && (errorFileName[0] == '\'')) { errorFileName = errorFileName + 1; errorFileName[strlen(errorFileName) - 1] = 0x0; }
    //
    if (inputFileName) params->stdin = fopen(inputFileName, "r");
    if (params->stdin == NULL) params->stdin = thread_stdin; // open did not work
    if (outputFileName) params->stdout = fopen(outputFileName, "w");
    if (params->stdout == NULL) params->stdout = thread_stdout; // open did not work
    if (sharedErrorOutput) params->stderr = params->stdout;
    else if (errorFileName) params->stderr = fopen(errorFileName, "w");
    if (params->stderr == NULL) params->stderr = thread_stderr; // open did not work
    int argc = 0;
    size_t numSpaces = 0;
    // the number of arguments is *at most* the number of spaces plus one
    char* str = command;
    while(*str) if (*str++ == ' ') ++numSpaces;
    char** argv = (char **)malloc(sizeof(char*) * (numSpaces + 2));
    bool* dontExpand = malloc(sizeof(bool) * (numSpaces + 2));
    // n spaces = n+1 arguments, plus null at the end
    str = command;
    while (*str) {
        argv[argc] = str;
        dontExpand[argc] = false;
        argc += 1;
        if (str[0] == '\'') { // argument begins with a quote.
            // everything until next quote is part of the argument
            argv[argc-1] = str + 1;
            char* end = strstr(argv[argc-1], "'");
            if (!end) break;
            end[0] = 0x0;
            str = end + 1;
            dontExpand[argc-1] = true; // don't expand arguments in quotes
        } else if (str[0] == '\"') { // argument begins with a double quote.
            // everything until next double quote is part of the argument
            argv[argc-1] = str + 1;
            char* end = strstr(argv[argc-1], "\"");
            if (!end) break;
            end[0] = 0x0;
            str = end + 1;
            dontExpand[argc-1] = true; // don't expand arguments in quotes
        } else {
            // skip to next space:
            char* end = strstr(str, " ");
            if (!end) break;
            end[0] = 0x0;
            str = end + 1;
        }
        if ((argc == 1) && (argv[0][0] == '/') && (access(argv[0], R_OK) == -1)) {
            // argv[0] is a file that doesn't exist. Probably one of our commands.
            // Replace with its name:
            char* newName = basename(argv[0]);
            argv[0] = realloc(argv[0], strlen(newName));
            strcpy(argv[0], newName);
        }
        assert(argc < numSpaces + 2);
        while (str && (str[0] == ' ')) str++; // skip multiple spaces
    }
    argv[argc] = NULL;
    long returnValue = 0;
    if (argc != 0) {
        // So far, all arguments are pointers into originalCommand.
        // We need to change them (environment variables expansion, ~ expansion, etc)
        // Duplicate everything so we can realloc:
        char** argv_copy = (char **)malloc(sizeof(char*) * (argc + 1));
        for (int i = 0; i < argc; i++) argv_copy[i] = strdup(argv[i]);
        argv_copy[argc] = NULL;
        free(argv);
        argv = argv_copy;
        // We have the arguments. Parse them for environment variables, ~, etc.
        for (int i = 1; i < argc; i++) if (!dontExpand[i]) argv[i] = parseArgument(argv[i], argv[0]);
        free(dontExpand);
        // Now call the actual command:
        // - is argv[0] a command that refers to a file? (either absolute path, or in $PATH)
        //   if so, does it exist, does it have +x bit set, does it have #! python or #! lua on the first line?
        //   if yes to all, call the relevant interpreter. Works for hg, for example.
        if (argv[0][0] == '\\') {
            // Just remove the \ at the beginning
            // There can be several versions of a command (e.g. ls as precompiled and ls written in Python)
            // The executable file has precedence, unless the user has specified they want the original
            // version, by prefixing it with \. So "\ls" == always "our" ls. "ls" == maybe ~/Library/bin/ls
            // (if it exists).
            size_t len_with_terminator = strlen(argv[0] + 1) + 1;
            memmove(argv[0], argv[0] + 1, len_with_terminator);
        } else  {
            NSString* commandName = [NSString stringWithCString:argv[0]];
            BOOL isDir = false;
            BOOL cmdIsAFile = false;
            if ([commandName hasPrefix:@"~"]) commandName = [commandName stringByExpandingTildeInPath];
            if ([[NSFileManager defaultManager] fileExistsAtPath:commandName isDirectory:&isDir]  && (!isDir)) {
                // File exists, is a file.
                struct stat sb;
                if ((stat(commandName.UTF8String, &sb) == 0) && S_ISXXX(sb.st_mode)) {
                    // File exists, is executable, not a directory.
                    cmdIsAFile = true;
                }
            }
            // We go through the path, because that command may be a file in the path
            // i.e. user called /usr/local/bin/hg and it's ~/Library/bin/hg
            NSString* checkingPath = [NSString stringWithCString:getenv("PATH") encoding:NSUTF8StringEncoding];
            if (! [fullCommandPath isEqualToString:checkingPath]) {
                fullCommandPath = checkingPath;
                directoriesInPath = [fullCommandPath componentsSeparatedByString:@":"];
            }
            for (NSString* path in directoriesInPath) {
                // If we don't have access to the path component, there's no point in continuing:
                if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) continue;
                if (!isDir) continue; // same in the (unlikely) event the path component is not a directory
                NSString* locationName;
                if (!cmdIsAFile) {
                    locationName = [path stringByAppendingPathComponent:commandName];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:locationName isDirectory:&isDir]) continue;
                    if (isDir) continue;
                    // isExecutableFileAtPath replies "NO" even if file has x-bit set.
                    // if (![[NSFileManager defaultManager]  isExecutableFileAtPath:cmdname]) continue;
                    struct stat sb;
                    if (!((stat(locationName.UTF8String, &sb) == 0) && S_ISXXX(sb.st_mode))) continue;
                    // File exists, is executable, not a directory.
                } else
                    // if (cmdIsAFile) we are now ready to execute this file:
                    locationName = commandName;
                NSData *data = [NSData dataWithContentsOfFile:locationName];
                NSString *fileContent = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSRange firstLineRange = [fileContent rangeOfString:@"\n"];
                if (firstLineRange.location == NSNotFound) firstLineRange.location = 0;
                firstLineRange.length = firstLineRange.location;
                firstLineRange.location = 0;
                NSString* firstLine = [fileContent substringWithRange:firstLineRange];
                if ([firstLine hasPrefix:@"#!"]) {
                    // So long as the 1st line begins with "#!" and contains "python" we accept it as a python script
                    // "#! /usr/bin/python", "#! /usr/local/bin/python" and "#! /usr/bin/myStrangePath/python" are all OK.
                    // We also accept "#! /usr/bin/env python" because it is used.
                    // TODO: only accept "python" or "python2" at the end of the line
                    // executable scripts files. Python and lua:
                    // 1) get script language name
                    if ([firstLine containsString:@"python"]) {
                        scriptName = "python";
                    } else if ([firstLine containsString:@"lua"]) {
                        scriptName = "lua";
                    }
                    if (scriptName) {
                        // 2) insert script language at beginning of argument list
                        argc += 1;
                        argv = (char **)realloc(argv, sizeof(char*) * argc);
                        // Move everything one step up
                        for (int i = argc; i >= 1; i--) { argv[i] = argv[i-1]; }
                        argv[1] = realloc(argv[1], strlen(locationName.UTF8String));
                        strcpy(argv[1], locationName.UTF8String);
                        argv[0] = strdup(scriptName); // this one is new
                        break;
                    }
                }
                if (cmdIsAFile) break; // else keep going through the path elements.
            }
        }
        // fprintf(thread_stderr, "Command after parsing: ");
        // for (int i = 0; i < argc; i++)
        //    fprintf(thread_stderr, "[%s] ", argv[i]);
        // We've reached this point: either the command is a file, from a script we support,
        // and we have inserted the name of the script at the beginning, or it is a builtin command
        int (*function)(int ac, char** av) = NULL;
        if (commandList == nil) initializeCommandList();
        NSString* commandName = [NSString stringWithCString:argv[0] encoding:NSUTF8StringEncoding];
        NSArray* commandStructure = [commandList objectForKey: commandName];
        void* handle = NULL;
        if (commandStructure != nil) {
            NSString* libraryName = commandStructure[0];
            if ([libraryName isEqualToString: @"SELF"]) handle = RTLD_SELF;  // commands defined in ios_system.framework
            else if ([libraryName isEqualToString: @"MAIN"]) handle = RTLD_MAIN_ONLY; // commands defined in main program
            else handle = dlopen(libraryName.UTF8String, RTLD_LAZY | RTLD_GLOBAL); // commands defined in dynamic library
#ifdef SIDELOADING
            if (handle == NULL) fprintf(thread_stderr, "Failed loading %s from %s, cause = %s\n", commandName.UTF8String, libraryName.UTF8String, dlerror());
#endif
            NSString* functionName = commandStructure[1];
            function = dlsym(handle, functionName.UTF8String);
#ifdef SIDELOADING
            if (function == NULL) fprintf(thread_stderr, "Failed loading %s from %s, cause = %s\n", commandName.UTF8String, libraryName.UTF8String, dlerror());
#endif
        }
        if (function) {
            // We run the function in a thread because there are several
            // points where we can exit from a shell function.
            // Commands call pthread_exit instead of exit
            // thread is attached, could also be un-attached
            pthread_t _tid;
            params->argc = argc;
            params->argv = argv;
            params->function = function;
            params->dlHandle = handle;
            params->isPipe = (params->stdout != thread_stdout);
            if (isMainThread) {
                // Send a signal to the system that we're going to change the current directory:
                NSString* currentPath = [[NSFileManager defaultManager] currentDirectoryPath];
                NSURL* currentURL = [NSURL fileURLWithPath:currentPath];
                NSFileCoordinator *fileCoordinator =  [[NSFileCoordinator alloc] initWithFilePresenter:nil];
                [fileCoordinator coordinateWritingItemAtURL:currentURL options:0 error:NULL byAccessor:^(NSURL *currentURL) {
                    isMainThread = false;
                    pthread_create(&_tid, NULL, run_function, params);
                    // Wait for this process to finish:
                    pthread_join(_tid, NULL);
                    // If there are auxiliary process, also wait for them:
                    if (lastThreadId > 0) pthread_join(lastThreadId, NULL);
                    lastThreadId = 0;
                    isMainThread = true;
                }];
            } else {
                // Don't send signal if not in main thread. Also, don't join threads.
                pthread_create(&_tid, NULL, run_function, params);
                // The last command on the command line (with multiple pipes) will be created first
                if (lastThreadId == 0) lastThreadId = _tid;
            }
        } else {
            if ((handle != NULL) && (handle != RTLD_SELF)
                && (handle != RTLD_MAIN_ONLY)
                && (handle != RTLD_DEFAULT) && (handle != RTLD_NEXT))
                dlclose(handle);
            fprintf(thread_stderr, "%s: command not found\n", argv[0]);
            returnValue = 127;
            // TODO: this should also raise an exception, for python scripts
        } // if (function)
    } else { // argc != 0
        free(argv); // argv is otherwise freed in cleanup_function
    }
    free(originalCommand); // releases cmd, which was a strdup of inputCommand
    // Did we write anything?
    if (errorFileName) returnValue = ftell(thread_stderr);
    else if (sharedErrorOutput && outputFileName) returnValue = ftell(thread_stdout);
    return (returnValue); // 0 = success, not 0 = failure
}
