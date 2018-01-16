//
//  ios_system.m
//
//  Created by Nicolas Holzschuch on 17/11/2017.
//  Copyright © 2017 N. Holzschuch. All rights reserved.
//

#import <Foundation/Foundation.h>

// ios_system(cmd): Executes the command in "cmd". The goal is to be a drop-in replacement for system(), as much as possible.
// We assume cmd is the command. If vim has prepared '/bin/sh -c "(command -arguments) < inputfile > outputfile",
// it is easier to remove the "/bin/sh -c" part before calling ios_system than inside ios_system.
// See example in os_unix.c
//
// ios_executable(cmd): returns true if the command is one of the commands defined in ios_system, and can be executed.
// This is because mch_can_exe (called by executable()) checks for the existence of binaries with the same name in the
// path. Our commands don't exist in the path. 

#include <pthread.h>
#include <sys/stat.h>
#define S_ISXXX(m) ((m) & (S_IXUSR | S_IXGRP | S_IXOTH)) // is executable, looking at "x" bit. Other methods fails on iOS

// Note: we could use dlsym() to make this code simpler, but it would also make it harder
// to be accepted in the AppleStore. Dynamic libraries are already loaded, so it would be:
// function = dlsym(argv[0] + "_main", RTLD_DEFAULT);

#define FILE_UTILITIES   // file_cmds_ios
#define ARCHIVE_UTILITIES // libarchive_ios
#define SHELL_UTILITIES  // shell_cmds_ios
#define TEXT_UTILITIES  // text_cmds_ios
// to activate CURL, you need openSSL.framework and libssh2.framework
// see, https://github.com/blinksh/blink or https://github.com/x2on/libssh2-for-iOS
#define CURL_COMMANDS
// to activate TEX_COMMANDS, you need the lib-tex libraries:
// See: https://github.com/holzschu/lib-tex
// #define TEX_COMMANDS    // pdftex, luatex, bibtex and the like
// to activate Python, you need python-ios: https://github.com/holzschu/python_ios
// #define FEAT_PYTHON
// to activate Lua, you need lua-ios: https://github.com/holzschu/lua_ios
// #define FEAT_LUA

//#define NETWORK_UTILITIES


#ifdef FILE_UTILITIES
// Most useful file utilities (file_cmds_ios)
extern int ls_main(int argc, char *argv[]);
extern int touch_main(int argc, char *argv[]);
extern int rm_main(int argc, char *argv[]);
extern int cp_main(int argc, char *argv[]);
extern int ln_main(int argc, char *argv[]);
extern int mv_main(int argc, char *argv[]);
extern int mkdir_main(int argc, char *argv[]);
extern int rmdir_main(int argc, char *argv[]);
// Useful
extern int du_main(int argc, char *argv[]);
extern int df_main(int argc, char *argv[]);
extern int chksum_main(int argc, char *argv[]);
extern int compress_main(int argc, char *argv[]);
extern int gzip_main(int argc, char *argv[]);
// Most likely useless in a sandboxed environment, but provided nevertheless
extern int chmod_main(int argc, char *argv[]);
extern int chflags_main(int argc, char *argv[]);
extern int chown_main(int argc, char *argv[]);
extern int stat_main(int argc, char *argv[]);
#endif
#ifdef ARCHIVE_UTILITIES
// from libarchive:
extern int tar_main(int argc, char **argv);
#endif
#ifdef CURL_COMMANDS
extern int curl_main(int argc, char **argv);
#endif

#ifdef SHELL_UTILITIES
extern int date_main(int argc, char *argv[]);
extern int echo_main(int argc, char *argv[]);
extern int env_main(int argc, char *argv[]);     // does the same as printenv
extern int hostname_main(int argc, char *argv[]);
extern int id_main(int argc, char *argv[]); // also groups, whoami
extern int printenv_main(int argc, char *argv[]);
extern int pwd_main(int argc, char *argv[]);
extern int uname_main(int argc, char *argv[]);
extern int w_main(int argc, char *argv[]); // also uptime
#endif
#ifdef TEXT_UTILITIES
extern int cat_main(int argc, char *argv[]);
extern int grep_main(int argc, char *argv[]);
extern int wc_main(int argc, char *argv[]);
extern int ed_main(int argc, char *argv[]);
extern int tr_main(int argc, char *argv[]);
extern int sed_main(int argc, char *argv[]);
extern int awk_main(int argc, char *argv[]);
#endif
#ifdef FEAT_LUA
extern int lua_main(int argc, char *argv[]);
extern int luac_main(int argc, char *argv[]);
#endif
#ifdef FEAT_PYTHON
extern int python_main(int argc, char **argv);
#endif
#ifdef TEX_COMMANDS
extern int bibtex_main(int argc, char *argv[]);
extern int dllluatexmain(int argc, char *argv[]);
extern int dllpdftexmain(int argc, char *argv[]);
#endif
// local commands
static int setenv_main(int argc, char *argv[]);
static int unsetenv_main(int argc, char *argv[]);
static int cd_main(int argc, char *argv[]);

extern int    __db_getopt_reset;
typedef struct _functionParameters {
    int argc;
    char** argv;
    int (*function)(int ac, char** av);
} functionParameters;

static void* run_function(void* parameters) {
    static bool isMainThread = true;
    // re-initialize for getopt:
    optind = 1;
    opterr = 1;
    optreset = 1;
    __db_getopt_reset = 1;
    functionParameters *p = (functionParameters *) parameters;
    // Send a signal to the system that we're going to change the current directory:
    if (isMainThread) {
        NSString* currentPath = [[NSFileManager defaultManager] currentDirectoryPath];
        NSURL* currentURL = [NSURL fileURLWithPath:currentPath];
        NSFileCoordinator *fileCoordinator =  [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [fileCoordinator coordinateWritingItemAtURL:currentURL options:0 error:NULL byAccessor:^(NSURL *currentURL) {
            isMainThread = false;
            p->function(p->argc, p->argv);
            isMainThread = true;
        }];
    } else p->function(p->argc, p->argv); // but don't do it if a command starts another command (would be overkill)
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
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    previousDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
    
    // Where the executables are stored: $PATH + ~/Library/bin + ~/Documents/bin
    // Add content of old PATH to this. PATH *is* defined in iOS, surprising as it may be.
    // I'm not going to erase it, so we just add ourselves.
    // Sometimes, we go through main several times, so make sure we only append to PATH once
    NSString* checkingPath = [NSString stringWithCString:getenv("PATH") encoding:NSASCIIStringEncoding];
    if (! [fullCommandPath isEqualToString:checkingPath]) {
        fullCommandPath = checkingPath;
    }
    if (![fullCommandPath containsString:@"Library/bin"]) {
        NSString *binPath = [libPath stringByAppendingPathComponent:@"bin"];
        fullCommandPath = [[binPath stringByAppendingString:@":"] stringByAppendingString:fullCommandPath];
    }
    if (![fullCommandPath containsString:@"Documents/bin"]) {
        NSString *binPath = [docsPath stringByAppendingPathComponent:@"bin"];
        fullCommandPath = [[binPath stringByAppendingString:@":"] stringByAppendingString:fullCommandPath];
    }
    setenv("APPDIR", [[NSBundle mainBundle] resourcePath].UTF8String, 1);
    setenv("PATH", fullCommandPath.UTF8String, 1); // 1 = override existing value
    setenv("TERM", "xterm", 1); // 1 = override existing value
    directoriesInPath = [fullCommandPath componentsSeparatedByString:@":"];
    
    // We can't write in $HOME so we need to set the position of config files:
    setenv("SSH_HOME", docsPath.UTF8String, 0);  // SSH keys in ~/Documents/.ssh/
    setenv("CURL_HOME", docsPath.UTF8String, 0); // CURL config in ~/Documents/
    setenv("TMPDIR", NSTemporaryDirectory().UTF8String, 0); // tmp directory
    setenv("SSL_CERT_FILE", [docsPath stringByAppendingPathComponent:@"cacert.pem"].UTF8String, 0); // SLL cacert.pem in ~/Documents/cacert.pem
    // iOS already defines "HOME" as the home dir of the application
#ifdef FEAT_PYTHON
    // if we use Python, we define a few more environment variables:
    setenv("PYTHONHOME", libPath.UTF8String, 0);  // Python scripts in ~/Library/lib/python3.6/
    setenv("PYZMQ_BACKEND", "cffi", 0);
    setenv("JUPYTER_CONFIG_DIR", [docsPath stringByAppendingPathComponent:@".jupyter"].UTF8String, 0);
    // hg config file in ~/Documents/.hgrc
    setenv("HGRCPATH", [docsPath stringByAppendingPathComponent:@".hgrc"].UTF8String, 0);
#endif
}

static char* parseArgument(char* argument, char* command) {
    // expand all environment variables, convert "~" to $HOME (only if localFile)
    // we also pass the shell command for some specific behaviour (don't do this for that command)
    NSString* argumentString = [NSString stringWithCString:argument encoding:NSASCIIStringEncoding];
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
            NSString* replacement_string = [NSString stringWithCString:variable encoding:NSASCIIStringEncoding];
            variable_string = [[NSString stringWithCString:"$" encoding:NSASCIIStringEncoding] stringByAppendingString:variable_string];
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
                replacement_string = [NSString stringWithCString:(getenv("HOME")) encoding:NSASCIIStringEncoding];
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
            if (miniRoot == nil) homeDir = [NSString stringWithCString:(getenv("HOME")) encoding:NSASCIIStringEncoding];
            else homeDir = miniRoot;
            // Only 1 possibility: ":~" (same as $HOME)
            if (homeDir.length > 0) {
                if ([argumentString containsString:@":~/"]) {
                    NSString* test_string = @":~/";
                    NSString* replacement_string = [[NSString stringWithCString:":" encoding:NSASCIIStringEncoding] stringByAppendingString:homeDir];
                    replacement_string = [replacement_string stringByAppendingString:[NSString stringWithCString:"/" encoding:NSASCIIStringEncoding]];
                    argumentString = [argumentString stringByReplacingOccurrencesOfString:test_string withString:replacement_string];
                } else if ([argumentString hasSuffix:@":~"]) {
                    NSString* test_string = @":~";
                    NSString* replacement_string = [[NSString stringWithCString:":" encoding:NSASCIIStringEncoding] stringByAppendingString:homeDir];
                    argumentString = [argumentString stringByReplacingOccurrencesOfString:test_string withString:replacement_string options:NULL range:NSMakeRange([argumentString length] - 2, 2)];
                } else if ([argumentString hasSuffix:@":"]) {
                    NSString* test_string = @":";
                    NSString* replacement_string = [[NSString stringWithCString:":" encoding:NSASCIIStringEncoding] stringByAppendingString:homeDir];
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
    commandList = @{
#ifdef FILE_UTILITIES
                    // Commands from Apple file_cmds:
                    @"ls" : [NSValue valueWithPointer: ls_main],
                    @"touch" : [NSValue valueWithPointer: touch_main],
                    @"rm" : [NSValue valueWithPointer: rm_main],
                    @"cp" : [NSValue valueWithPointer: cp_main],
                    @"ln" : [NSValue valueWithPointer: ln_main],
                    @"link" : [NSValue valueWithPointer: ln_main],
                    @"mv" : [NSValue valueWithPointer: mv_main],
                    @"mkdir" : [NSValue valueWithPointer: mkdir_main],
                    @"rmdir" : [NSValue valueWithPointer: rmdir_main],
//                    @"chown" : [NSValue valueWithPointer: chown_main],
//                    @"chgrp" : [NSValue valueWithPointer: chown_main],
                    @"chflags": [NSValue valueWithPointer: chflags_main],
//                    @"chmod": [NSValue valueWithPointer: chmod_main],
                    @"du"   : [NSValue valueWithPointer: du_main],
//                    @"df"   : [NSValue valueWithPointer: df_main],
                    @"chksum" : [NSValue valueWithPointer: chksum_main],
                    @"sum"    : [NSValue valueWithPointer: chksum_main],
                    @"stat"   : [NSValue valueWithPointer: stat_main],
                    @"readlink": [NSValue valueWithPointer: stat_main],
                    @"compress": [NSValue valueWithPointer: compress_main],
                    @"uncompress": [NSValue valueWithPointer: compress_main],
                    @"gzip"   : [NSValue valueWithPointer: gzip_main],
                    @"gunzip" : [NSValue valueWithPointer: gzip_main],
#endif
#ifdef ARCHIVE_UTILITIES
                    // from libarchive:
                    @"tar"    : [NSValue valueWithPointer: tar_main],
#endif
#ifdef SHELL_UTILITIES
                    // Commands from Apple shell_cmds:
                    @"echo" : [NSValue valueWithPointer: echo_main], 
                    @"printenv": [NSValue valueWithPointer: printenv_main],
                    @"pwd"    : [NSValue valueWithPointer: pwd_main],
                    @"uname"  : [NSValue valueWithPointer: uname_main],
                    @"date"   : [NSValue valueWithPointer: date_main],
                    @"env"    : [NSValue valueWithPointer: env_main],
//                    @"id"     : [NSValue valueWithPointer: id_main],
//                    @"groups" : [NSValue valueWithPointer: id_main],
                    @"whoami" : [NSValue valueWithPointer: id_main],
                    @"uptime" : [NSValue valueWithPointer: w_main],
//                    @"w"      : [NSValue valueWithPointer: w_main],
#endif
#ifdef TEXT_UTILITIES
                    // Commands from Apple text_cmds:
                    @"cat"    : [NSValue valueWithPointer: cat_main],
                    @"wc"     : [NSValue valueWithPointer: wc_main],
                    @"tr"     : [NSValue valueWithPointer: tr_main],
                    // compiled, but deactivated until we have interactive mode
//                    @"ed"     : [NSValue valueWithPointer: ed_main],
//                    @"red"     : [NSValue valueWithPointer: ed_main],
                    @"sed"     : [NSValue valueWithPointer: sed_main],
                    @"awk"     : [NSValue valueWithPointer: awk_main],
                    @"grep"   : [NSValue valueWithPointer: grep_main],
                    @"egrep"  : [NSValue valueWithPointer: grep_main],
                    @"fgrep"  : [NSValue valueWithPointer: grep_main],
#endif
#ifdef NETWORK_UTILITIES
                    // Use with caution. Doesn't make sense except inside a terminal.
                    // Commands from Apple network_cmds:
                    @"ping"  : [NSValue valueWithPointer: ping_main],
#endif
#ifdef CURL_COMMANDS
                    // From curl. curl with ssh requires keys, and thus keys generation / management.
                    // We assume you moved over the keys, known_host files from elsewhere
                    // http, https, ftp... should be OK.
                    @"curl"   : [NSValue valueWithPointer: curl_main],
                    // scp / sftp require conversion to curl, rewriting arguments
                    @"scp"    : [NSValue valueWithPointer: curl_main],
                    @"sftp"   : [NSValue valueWithPointer: curl_main],
#endif
#ifdef FEAT_PYTHON
                    // from python:
                    @"python"  : [NSValue valueWithPointer: python_main],
#endif
#ifdef FEAT_LUA
                    // from lua:
                    @"lua"     : [NSValue valueWithPointer: lua_main],
                    @"luac"    : [NSValue valueWithPointer: luac_main],
#endif
#ifdef TEX_COMMANDS
                    // from TeX:
                    // LuaTeX:
                    @"luatex"     : [NSValue valueWithPointer: dllluatexmain],
                    @"lualatex"     : [NSValue valueWithPointer: dllluatexmain],
                    @"texlua"     : [NSValue valueWithPointer: dllluatexmain],
                    @"texluac"     : [NSValue valueWithPointer: dllluatexmain],
                    @"dviluatex"     : [NSValue valueWithPointer: dllluatexmain],
                    @"dvilualatex"     : [NSValue valueWithPointer: dllluatexmain],
                    // pdfTeX
                    @"amstex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"cslatex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"csplain"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"eplain"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"etex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"jadetex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"latex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"mex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"mllatex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"mltex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"pdfcslatex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"pdfcsplain"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"pdfetex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"pdfjadetex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"pdflatex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"pdftex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"pdfmex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"pdfxmltex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"texsis"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"utf8mex"     : [NSValue valueWithPointer: dllpdftexmain],
                    @"xmltex"     : [NSValue valueWithPointer: dllpdftexmain],
                    // XeTeX:
                    // @"xetex"     : [NSValue valueWithPointer: dllxetexmain],
                    // @"xelatex"     : [NSValue valueWithPointer: dllxetexmain],
                    // BibTeX
                    @"bibtex"     : [NSValue valueWithPointer: bibtex_main],
#endif
                    // local commands
                    @"setenv"     : [NSValue valueWithPointer: setenv_main],
                    @"unsetenv"     : [NSValue valueWithPointer: unsetenv_main],
                    @"cd"     : [NSValue valueWithPointer: cd_main],
                    };
}

static int setenv_main(int argc, char** argv) {
    if (argc <= 1) return env_main(argc, argv);
    if (argc > 3) {
        fprintf(stderr, "setenv: Too many arguments\n"); fflush(stderr);
        return 0;
    }
    // setenv VARIABLE value
    if (argv[2] != NULL) setenv(argv[1], argv[2], 1);
    else setenv(argv[1], "", 1); // if there's no value, pass an empty string instead of a null pointer
    return 0;
}

static int unsetenv_main(int argc, char** argv) {
    if (argc <= 1) {
        fprintf(stderr, "unsetenv: Too few arguments\n"); fflush(stderr);
        return 0;
    }
    // unsetenv acts on all parameters
    for (int i = 1; i < argc; i++) unsetenv(argv[i]);
    return 0;
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

static int cd_main(int argc, char** argv) {
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
                        fprintf(stderr, "cd: %s: permission denied\n", [newDir UTF8String]);
                        [[NSFileManager defaultManager] changeCurrentDirectoryPath:miniRoot];
                        currentDir = miniRoot;
                    }
                    previousDirectory = currentDir;
                } else fprintf(stderr, "cd: %s: permission denied\n", [newDir UTF8String]);
            }
            else  fprintf(stderr, "cd: %s: not a directory\n", [newDir UTF8String]);
        } else {
            fprintf(stderr, "cd: %s: no such file or directory\n", [newDir UTF8String]);
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

int ios_executable(char* inputCmd) {
 // returns 1 if this is one of the commands we define in ios_system, 0 otherwise
    int (*function)(int ac, char** av) = NULL;
    if (commandList == nil) initializeCommandList();
    NSString* commandName = [NSString stringWithCString:inputCmd encoding:NSASCIIStringEncoding];
    function = [[commandList objectForKey: commandName] pointerValue];
    if (function) return 1;
    else return 0;
}

// For customization:
// replaces a function pointer (e.g. ls_main) with another one, provided by the user (ls_mine_main)
// if the function does not exist, add it to the list
// if "allOccurences" is true, search for all commands that share the same function, replace them too.
// ("compress" and "uncompress" both point to compress_main. You probably want to replace both, but maybe
// you just happen to have a very fast uncompress, different from compress).
void replaceCommand(NSString* commandName, int (*newFunction)(int argc, char *argv[]), bool allOccurences) {
    if (commandList == nil) initializeCommandList();
    
    int (*oldFunction)(int ac, char** av) = [[commandList objectForKey: commandName] pointerValue];
    NSMutableDictionary *mutableDict = [commandList mutableCopy];
    mutableDict[commandName] = [NSValue valueWithPointer: newFunction];
    
    if (oldFunction && allOccurences) {
        // scan through all dictionary entries
        
        for (NSString* existingCommand in mutableDict.allKeys) {
            int (*existingFunction)(int ac, char** av) = [[mutableDict objectForKey: existingCommand] pointerValue];
            if (existingFunction == oldFunction) {
                [mutableDict setValue: [NSValue valueWithPointer: newFunction] forKey: existingCommand];
            }
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

int ios_system(char* inputCmd) {
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
    
    char* cmd = strdup(inputCmd);
    char* maxPointer = cmd + strlen(cmd);
    char* originalCommand = cmd;
    // fprintf(stderr, "Command sent: %s \n", cmd); fflush(stderr);
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
    // fprintf(stderr, "Command sent: %s \n", command);
    // Search for input, output and error redirection
    // They can be in any order, although the usual are:
    // command < input > output 2> error, command < input > output 2>&1 or command < input >& output
    // The last two are equivalent. Vim prefers the second.
    // Search for input file "< " and output file " >"
    if (!inputFileMarker) inputFileMarker = command;
    outputFileMarker = inputFileMarker;
    // scan until first "<"
    inputFileMarker = strstr(inputFileMarker, "<");
    // scan until first non-space character:
    if (inputFileMarker) {
        inputFileName = inputFileMarker + 1; // skip past '<'
        // skip past all spaces
        while ((inputFileName[0] == ' ') && strlen(inputFileName) > 0) inputFileName++;
    }
    // Must scan in strstr by reverse order of inclusion. So "2>&1" before "2>" before ">"
    errorFileMarker = strstr (outputFileMarker,"&>"); // both stderr/stdout sent to same file
    // output file name will be after "&>"
    if (errorFileMarker) { outputFileName = errorFileMarker + 2; outputFileMarker = errorFileMarker; }
    else {
        errorFileMarker = strstr (outputFileMarker,"2>&1| tee "); // Same, but expressed differently
        if (errorFileMarker) { outputFileName = errorFileMarker + 10; outputFileMarker = errorFileMarker; }
        else {
            errorFileMarker = strstr (outputFileMarker,"2>&1"); // Same, but output file name will be after ">"
            if (errorFileMarker) {
                outputFileMarker = strstr(outputFileMarker, ">");
                if (outputFileMarker) outputFileName = outputFileMarker + 1; // skip past '>'
            }
        }
    }
    if (errorFileMarker) { sharedErrorOutput = true; }
    else {
        // specific name for error file?
        errorFileMarker = strstr(outputFileMarker,"2>");
        if (errorFileMarker) {
            errorFileName = errorFileMarker + 2; // skip past "2>"
            // skip past all spaces:
            while ((errorFileName[0] == ' ') && strlen(errorFileName) > 0) errorFileName++;
        }
    }
    // scan until first ">"
    if (!sharedErrorOutput) {
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
        }
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
    if (outputFileMarker) outputFileMarker[0] = 0x0;
    if (errorFileMarker) errorFileMarker[0] = 0x0;
    // Store previous values of stdin, stdout, stderr:
    // fprintf(stdout, "before, stderr = %x\n", (void*)stderr);
    // strip filenames of quotes, if any:
    if (outputFileName && (outputFileName[0] == '\'')) { outputFileName = outputFileName + 1; outputFileName[strlen(outputFileName) - 1] = 0x0; }
    if (inputFileName && (inputFileName[0] == '\'')) { inputFileName = inputFileName + 1; inputFileName[strlen(inputFileName) - 1] = 0x0; }
    if (errorFileName && (errorFileName[0] == '\'')) { errorFileName = errorFileName + 1; errorFileName[strlen(errorFileName) - 1] = 0x0; }
    FILE* push_stdin = stdin;
    FILE* push_stdout = stdout;
    FILE* push_stderr = stderr;
    if (inputFileName) stdin = fopen(inputFileName, "r");
    if (stdin == NULL) stdin = push_stdin; // open did not work
    if (outputFileName) stdout = fopen(outputFileName, "w");
    if (stdout == NULL) stdout = push_stdout; // open did not work
    if (sharedErrorOutput && outputFileName) stderr = stdout;
    else if (errorFileName) stderr = fopen(errorFileName, "w");
    if (stderr == NULL) stderr = push_stderr; // open did not work
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
        assert(argc < numSpaces + 2);
        while (str && (str[0] == ' ')) str++; // skip multiple spaces
    }
    argv[argc] = NULL;
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
            argv[0] = argv[0] + 1;
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
            if ((!cmdIsAFile) && [commandName hasPrefix:@"/"]) {
                // cmd starts with "/" --> path to a command (that doesn't exist). Remove all directories at beginning:
                // This is a point where we are different from actual shells.
                // There is one version of each command, and we always assume it is the one you want.
                // /usr/sbin/ls and /usr/local/bin/ls will be the same.
                commandName = [commandName lastPathComponent];
                argv[0] = realloc(argv[0], strlen(commandName.UTF8String));
                strcpy(argv[0], commandName.UTF8String);
            }
            // We go through the path, because that command may be a file in the path
            // i.e. user called /usr/local/bin/hg and it's ~/Library/bin/hg
            NSString* checkingPath = [NSString stringWithCString:getenv("PATH") encoding:NSASCIIStringEncoding];
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
        // Because some commands change argv, keep a local copy for release.
        char** argv_ref = (char **)malloc(sizeof(char*) * (argc + 1));
        for (int i = 0; i < argc; i++) argv_ref[i] = argv[i];
        // fprintf(stderr, "Command after parsing: ");
        // for (int i = 0; i < argc; i++)
        //    fprintf(stderr, "[%s] ", argv[i]);
        // We've reached this point: either the command is a file, from a script we support,
        // and we have inserted the name of the script at the beginning, or it is a builtin command
        int (*function)(int ac, char** av) = NULL;
        if (commandList == nil) initializeCommandList();
        NSString* commandName = [NSString stringWithCString:argv[0] encoding:NSASCIIStringEncoding];
        // Insert code here. With #ifdef ???
        function = [[commandList objectForKey: commandName] pointerValue];
        if (function) {
            // We run the function in a thread because there are several
            // points where we can exit from a shell function.
            // Commands call pthread_exit instead of exit
            // thread is attached, could also be un-attached
            pthread_t _tid;
            functionParameters params;
            params.argc = argc;
            params.argv = argv;
            params.function = function;
            pthread_create(&_tid, NULL, run_function, &params);
            pthread_join(_tid, NULL);
        } else {
            // TODO: this should also raise an exception, for python scripts
            fprintf(stderr, "%s: command not found\n", argv[0]);
        } // if (function)
        for (int i = 0; i < argc; i++) free(argv_ref[i]);
        free(argv_ref);
    } // argc != 0
    free(argv);
    free(originalCommand); // releases cmd
    // Did we write anything?
    long numCharWritten = 0;
    if (errorFileName) numCharWritten = ftell(stderr);
    else if (sharedErrorOutput && outputFileName) numCharWritten = ftell(stdout);
    // restore previous values of stdin, stdout, stderr:
    if (inputFileName) fclose(stdin);
    if (outputFileName) fclose(stdout);
    if (!sharedErrorOutput && errorFileName) fclose(stderr);
    stdin = push_stdin;
    stdout = push_stdout;
    stderr = push_stderr;
    return (numCharWritten); // 0 = success, not 0 = failure
}
