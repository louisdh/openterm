/*	$NetBSD: tee.c,v 1.6 1997/10/20 00:37:11 lukem Exp $	*/

/*
 * Copyright (c) 1988, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <sys/cdefs.h>
#ifndef lint
__COPYRIGHT("@(#) Copyright (c) 1988, 1993\n\
	The Regents of the University of California.  All rights reserved.\n");
#endif /* not lint */

#ifndef lint
#if 0
static char sccsid[] = "@(#)tee.c	8.1 (Berkeley) 6/6/93";
#endif
__RCSID("$NetBSD: tee.c,v 1.6 1997/10/20 00:37:11 lukem Exp $");
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <locale.h>
#include <err.h>
#include "ios_error.h"

typedef struct _list {
	struct _list *next;
    FILE* stream;
	// int fd;
	char *name;
} LIST;
static LIST *head;

static void	add __P((FILE*, char *));
int	tee_main __P((int, char **));

int
tee_main(argc, argv)
	int argc;
	char *argv[];
{
	LIST *p;
    int n, rval;
    size_t wval;
    FILE* fd;
	char *bp;
	int append, ch, exitval;
	char *buf;
#define	BSIZE (8 * 1024)
    // iOS: initialize flags:
    append = 0; exitval = 0;
    rval = 0; wval = 0; fd = 0; n = 0; ch = 0;
    
    
	setlocale(LC_ALL, "");

	append = 0;
	while ((ch = getopt(argc, argv, "ai")) != -1)
		switch((char)ch) {
		case 'a':
			append = 1;
			break;
		case 'i':
			(void)signal(SIGINT, SIG_IGN);
			break;
		case '?':
		default:
			(void)fprintf(stderr, "usage: tee [-ai] [file ...]\n");
			exit(1);
		}
	argv += optind;
	argc -= optind;

    if ((buf = malloc((size_t)BSIZE)) == NULL) {
        fprintf(thread_stderr, "tee: malloc: %s\n", strerror(errno));
        pthread_exit(NULL);
        // err(1, "malloc");
    }

	add(thread_stdout, "stdout");

	for (exitval = 0; *argv; ++argv)
        if ((fd = fopen(*argv, append ? "a" : "w")) < 0) {
            fprintf(thread_stderr, "tee: %s: %s\n", *argv, strerror(errno));
			// warn("%s", *argv);
			exitval = 1;
		} else
			add(fd, *argv);

	while ((rval = read(fileno(thread_stdin), buf, BSIZE)) > 0)
		for (p = head; p; p = p->next) {
			n = rval;
			bp = buf;
			do {
				if ((wval = fwrite(bp, 1, n, p->stream)) != n) {
                    fprintf(thread_stderr, "tee: %s: %s\n", p->name, strerror(errno));
					// warn("%s", p->name);
					exitval = 1;
					break;
				}
				bp += wval;
			} while (n -= wval);
		}
	if (rval < 0) {
        fprintf(thread_stderr, "tee: %s: %s\n", "read", strerror(errno));
		// warn("read");
		exitval = 1;
	}

    for (p = head; p; p = p->next) {
        if (strcmp(p->name, "stdout") != 0) {
            if (fclose(p->stream) == -1) {
                fprintf(thread_stderr, "tee: %s: %s\n", p->name, strerror(errno));
                // warn("%s", p->name);
                exitval = 1;
            }
        }
	}

    free(buf);
    LIST *pnext;
    for (p = head; p; p = pnext) {
        pnext = p->next;
        free(p);
        p = NULL;
    }
    head = NULL;
    return exitval;
	// exit(exitval);
}

void
add(stream, name)
	FILE* stream;
	char *name;
{
	LIST *p;

    if ((p = malloc((size_t)sizeof(LIST))) == NULL) {
        fprintf(thread_stderr, "tee: malloc: %s\n", strerror(errno));
        pthread_exit(NULL);
		// err(1, "malloc");
    }
	p->stream = stream;
	p->name = name;
	p->next = head;
	head = p;
}
