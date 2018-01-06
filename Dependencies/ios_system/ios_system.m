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

extern int    __db_getopt_reset;
typedef struct _functionParameters {
    int argc;
    char** argv;
    int (*function)(int ac, char** av);
} functionParameters;

static void* run_function(void* parameters) {
    // re-initialize for getopt:
    optind = 1;
    opterr = 1;
    optreset = 1;
    __db_getopt_reset = 1;
    functionParameters *p = (functionParameters *) parameters;
    p->function(p->argc, p->argv);
    return NULL;
}

static NSDictionary *commandList = nil;
// do recompute directoriesInPath only if $PATH has changed
static NSString* fullCommandPath = @"";
static NSArray *directoriesInPath;


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
                    @"printenv": [NSValue valueWithPointer: printenv_main],
//                    @"pwd"    : [NSValue valueWithPointer: pwd_main],
                    @"uname"  : [NSValue valueWithPointer: uname_main],
                    @"date"   : [NSValue valueWithPointer: date_main],
//                    @"env"    : [NSValue valueWithPointer: env_main],
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
                    // @"scp"    : [NSValue valueWithPointer: curl_main],
                    // @"sftp"   : [NSValue valueWithPointer: curl_main],
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
                    };
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



char* commandsAsString() {

	initializeCommandList();

	NSError * err;
	NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:commandList.allKeys options:0 error:&err];
	NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

	return myString.cString;
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
        cmd = cmd + 1; // remove starting quote
        cmd[strlen(cmd) - 1] = 0x00; // remove ending quote
        assert(cmd + strlen(cmd) < maxPointer);
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
    // n spaces = n+1 arguments, plus null at the end
    str = command;
    while (*str) {
        argv[argc] = str;
        argc += 1;
        if (str[0] == '\'') { // argument begins with a quote.
            // everything until next quote is part of the argument
            argv[argc-1] = str + 1;
            char* end = strstr(argv[argc-1], "'");
            if (!end) break;
            end[0] = 0x0;
            str = end + 1;
        } if (str[0] == '\"') { // argument begins with a double quote.
            // everything until next double quote is part of the argument
            argv[argc-1] = str + 1;
            char* end = strstr(argv[argc-1], "\"");
            if (!end) break;
            end[0] = 0x0;
            str = end + 1;
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
                if ((stat(commandName.UTF8String, &sb) == 0 && (sb.st_mode & S_IXUSR))) {
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
                    if (!(stat(locationName.UTF8String, &sb) == 0 && (sb.st_mode & S_IXUSR))) continue;
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
                        for (int i = argc; i >= 1; i--) argv[i] = argv[i-1];
                        argv[1] = strdup(locationName.UTF8String);
                        argv[0] = strdup(scriptName);
                        break;
                    }
                }
                if (cmdIsAFile) break; // else keep going through the path elements.
            }
        }
        fprintf(stderr, "Command after parsing: ");
        // for (int i = 0; i < argc; i++)
        //    fprintf(stderr, "[%s] ", argv[i]);
        // We've reached this point: either the command is a file, from a script we support,
        // and we have inserted the name of the script at the beginning, or it is a builtin command
        int (*function)(int ac, char** av) = NULL;
        if (commandList == nil) initializeCommandList();
        NSString* commandName = [NSString stringWithCString:argv[0] encoding:NSASCIIStringEncoding];
        function = [[commandList objectForKey: commandName] pointerValue];
        if (function) {
            // We run the function in a thread because there are several
            // points where we can exit from a shell function.
            // Commands call pthread_exit instead of exit
            // thread is attached, could also be un-attached
            pthread_t _tid;
            functionParameters params; // = malloc(sizeof(functionParameters));;
            params.argc = argc;
            params.argv = argv;
            params.function = function;
            pthread_create(&_tid, NULL, run_function, &params);
            pthread_join(_tid, NULL);
            // free(params);
        } else {
            fprintf(stderr, "%s: command not found\n", argv[0]);
        }
    }
    // delete argv[0] and argv[1] *if* it's a command file
    if (scriptName) {
       free(argv[0]);
       free(argv[1]);
    }
    free(argv);
    free(originalCommand);
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
