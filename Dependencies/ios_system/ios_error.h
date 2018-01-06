//
//  error.h
//  shell_cmds_ios
//
//  Created by Nicolas Holzschuch on 16/06/2017.
//  Copyright © 2017 Nicolas Holzschuch. All rights reserved.
//

#ifndef ios_error_h
#define ios_error_h

#include <stdarg.h>
#include <pthread.h>

#define errx compileError
#define err compileError
#define warn compileError
#define warnx compileError

#define exit(a) pthread_exit(NULL)
#define _exit(a) pthread_exit(NULL)

#endif /* ios_error_h */
