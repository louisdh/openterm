/****************************************************************
Copyright (C) Lucent Technologies 1997
All Rights Reserved

Permission to use, copy, modify, and distribute this software and
its documentation for any purpose and without fee is hereby
granted, provided that the above copyright notice appear in all
copies and that both that the copyright notice and this
permission notice and warranty disclaimer appear in supporting
documentation, and that the name Lucent Technologies or any of
its entities not be used in advertising or publicity pertaining
to distribution of the software without specific, written prior
permission.

LUCENT DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS.
IN NO EVENT SHALL LUCENT OR ANY OF ITS ENTITIES BE LIABLE FOR ANY
SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
****************************************************************/

const char	*version = "version 20070501";

#define DEBUG
#include <stdio.h>
#include <ctype.h>
#include <locale.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include "awk.h"
#include "ytab.h"

// #ifdef __APPLE__
// #include "get_compat.h"
// #else
#define COMPAT_MODE(func, mode) 1
// #endif
#include "ios_error.h"

extern	char	**environ;
extern	__thread int	nfields;

__thread int	dbg	= 0;
__thread char	*cmdname;	/* gets argv[0] for error messages */
extern	__thread FILE	*yyin;	/* lex input file */
__thread char	*lexprog;	/* points to program argument if it exists */
extern	__thread int errorflag;	/* non-zero if any syntax errors; set by yyerror */
__thread int	compile_time = 2;	/* for error printing: */
				/* 2 = cmdline, 1 = compile, 0 = running */

#define	MAX_PFILE	20	/* max number of -f's */

static char	*pfile[MAX_PFILE];	/* program filenames from -f's */
static int	npfile = 0;	/* number of filenames */
static int	curpfile = 0;	/* current filename */

__thread int	safe	= 0;	/* 1 => "safe" mode */
__thread int	Unix2003_compat;

static void initializeVariables() {
    // initialize all flags:
    cmdname = NULL;
    extern __thread int    infunc;
    infunc = 0;    /* = 1 if in arglist or body of func */
    extern __thread int    inloop;
    inloop = 0;    /* = 1 if in while, for, do */

    extern __thread int    *setvec;
    extern __thread int    *tmpset;
    if (setvec != 0) {    /* first time through any RE */
        free(setvec); setvec = 0;
        free(tmpset); tmpset = 0;
    }
    yyin = 0;
    nfields    = 2; // MAXFLD
    npfile = 0;
    curpfile = 0;
    compile_time = 2;
    errorflag = 0;
    lexprog = 0;
    extern __thread int awk_firsttime;
    awk_firsttime = 1;
    
    extern __thread int lastfld;
    lastfld    = 0;    /* last used field */
    extern __thread int argno;
    argno    = 1;    /* current input argument number */
    if (symtab != NULL) {
        free(symtab->tab);
        free(symtab);
        symtab = NULL;
    }
    // Variables from lib.c
    if (record) { free(record); record = NULL;}
    recsize    = RECSIZE;
    extern __thread char    *fields;
    if (fields) { free(fields); fields = NULL; }
    extern __thread int fieldssize;
    fieldssize = RECSIZE;
    extern __thread Cell    **fldtab;    /* pointers to Cells */
    if (fldtab) { free(fldtab); fldtab = NULL; }
}


int awk_main(int argc, char *argv[])
{
	const char *fs = NULL;
    initializeVariables();

	setlocale(LC_CTYPE, "");
	setlocale(LC_NUMERIC, "C"); /* for parsing cmdline & prog */
	cmdname = argv[0];
	if (argc == 1) {
		fprintf(thread_stderr, 
		  "usage: %s [-F fs] [-v var=value] [-f progfile | 'prog'] [file ...]\n", 
		  cmdname);
        pthread_exit(NULL); // exit(1);
	}
	Unix2003_compat = COMPAT_MODE("bin/awk", "unix2003");
	signal(SIGFPE, fpecatch);
	yyin = NULL;
	symtab = makesymtab(NSYMTAB/NSYMTAB);
	while (argc > 1 && argv[1][0] == '-' && argv[1][1] != '\0') {
		if (strcmp(argv[1],"-version") == 0 || strcmp(argv[1],"--version") == 0) {
			fprintf(thread_stdout, "awk %s\n", version);
			pthread_exit(NULL); // exit(0);
			break;
		}
		if (strncmp(argv[1], "--", 2) == 0) {	/* explicit end of args */
			argc--;
			argv++;
			break;
		}
		switch (argv[1][1]) {
		case 's':
			if (strcmp(argv[1], "-safe") == 0)
				safe = 1;
			break;
		case 'f':	/* next argument is program filename */
			argc--;
			argv++;
			if (argc <= 1)
				FATAL("no program filename");
			if (npfile >= MAX_PFILE - 1)
				FATAL("too many -f options"); 
			pfile[npfile++] = argv[1];
			break;
		case 'F':	/* set field separator */
			if (argv[1][2] != 0) {	/* arg is -Fsomething */
				if (argv[1][2] == 't' && argv[1][3] == 0)	/* wart: t=>\t */
					fs = "\t";
				else if (argv[1][2] != 0)
					fs = &argv[1][2];
			} else {		/* arg is -F something */
				argc--; argv++;
				if (argc > 1 && argv[1][0] == 't' && argv[1][1] == 0)	/* wart: t=>\t */
					fs = "\t";
				else if (argc > 1 && argv[1][0] != 0)
					fs = &argv[1][0];
			}
			if (fs == NULL || *fs == '\0')
				WARNING("field separator FS is empty");
			break;
		case 'v':	/* -v a=1 to be done NOW.  one -v for each */
			if (argv[1][2] == '\0' && --argc > 1 && isclvar((++argv)[1]))
				setclvar(argv[1]);
			else
				FATAL("invalid -v option");
			break;
		case 'd':
			dbg = atoi(&argv[1][2]);
			if (dbg == 0)
				dbg = 1;
			fprintf(thread_stdout, "awk %s\n", version);
			break;
		default:
			WARNING("unknown option %s ignored", argv[1]);
			break;
		}
		argc--;
		argv++;
	}
	/* argv[1] is now the first argument */
	if (npfile == 0) {	/* no -f; first argument is program */
		if (argc <= 1) {
			if (dbg)
                pthread_exit(NULL); // exit(0);
			FATAL("no program given");
		}
		   dprintf( (thread_stdout, "program = |%s|\n", argv[1]) );
		lexprog = argv[1];
		argc--;
		argv++;
	}
	recinit(recsize);
	syminit();
	compile_time = 1;
	argv[0] = cmdname;	/* put prog name at front of arglist */
	   dprintf( (thread_stdout, "argc=%d, argv[0]=%s\n", argc, argv[0]) );
	arginit(argc, argv);
	if (!safe)
		envinit(environ);
	yyparse();
	setlocale(LC_NUMERIC, ""); /* back to whatever it is locally */
	if (fs)
		*FS = qstring(fs, '\0');
	   dprintf( (thread_stdout, "errorflag=%d\n", errorflag) );
	if (errorflag == 0) {
		compile_time = 0;
		run(winner);
        winner = NULL;
	} else
		bracecheck();
	return(errorflag);
}

int pgetc(void)		/* get 1 character from awk program */
{
	int c;

	for (;;) {
		if (yyin == NULL) {
			if (curpfile >= npfile)
				return EOF;
			if (strcmp(pfile[curpfile], "-") == 0)
				yyin = thread_stdin;
			else if ((yyin = fopen(pfile[curpfile], "r")) == NULL)
				FATAL("can't open file %s", pfile[curpfile]);
			lineno = 1;
		}
		if ((c = getc(yyin)) != EOF)
			return c;
		if (yyin != thread_stdin)
			fclose(yyin);
		yyin = NULL;
		curpfile++;
	}
}

char *cursource(void)	/* current source file name */
{
	if (npfile > 0)
		return pfile[curpfile];
	else
		return NULL;
}
