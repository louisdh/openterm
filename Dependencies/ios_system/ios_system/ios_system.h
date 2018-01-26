//
//  ios_system.h
//  ios_system
//
//  Created by Nicolas Holzschuch on 04/12/2017.
//  Copyright © 2017 Nicolas Holzschuch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//! Project version number for ios_system.
FOUNDATION_EXPORT double ios_systemVersionNumber;

//! Project version string for ios_system.
FOUNDATION_EXPORT const unsigned char ios_systemVersionString[];

// Thread-local input and output streams
extern __thread FILE* thread_stdin;
extern __thread FILE* thread_stdout;
extern __thread FILE* thread_stderr;

// In this header, you should import all the public headers of your framework using statements like #import <ios_system/PublicHeader.h>

int ios_executable(const char* inputCmd); // does this command exist? (executable file or builtin command)
int ios_system(const char* inputCmd); // execute this command (executable file or builtin command)
extern FILE *ios_popen(const char *command, const char *type); // Execute this command and pipe the result

extern NSString* commandsAsString(void);
extern NSArray* commandsAsArray(void);      // set of all commands, in an NSArrays
extern void initializeEnvironment(void);
extern int ios_setMiniRoot(NSString*);  // restric operations to a certain hierarchy
extern void replaceCommand(NSString* commandName, int (*newFunction)(int argc, char *argv[]), bool allOccurences);
