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

// In this header, you should import all the public headers of your framework using statements like #import <ios_system/PublicHeader.h>

int ios_executable(char* inputCmd); // does this command exist? (executable file or builtin command)
int ios_system(char* inputCmd); // execute this command (executable file or builtin command)

NSString* commandsAsString();
NSArray* commandsAsArray();
void initializeEnvironment();
int ios_setMiniRoot(NSString*);  // restric operations to a certain hierarchy
void replaceCommand(NSString* commandName, int (*newFunction)(int argc, char *argv[]), bool allOccurences);
