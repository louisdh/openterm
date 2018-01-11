#include <stdio.h>
#include "awk.h"
#include "ytab.h"
#include "ios_error.h"

static char *printname[95] = {
	(char *) "FIRSTTOKEN",	/* 258 */
	(char *) "PROGRAM",	/* 259 */
	(char *) "PASTAT",	/* 260 */
	(char *) "PASTAT2",	/* 261 */
	(char *) "XBEGIN",	/* 262 */
	(char *) "XEND",	/* 263 */
	(char *) "NL",	/* 264 */
	(char *) "ARRAY",	/* 265 */
	(char *) "MATCH",	/* 266 */
	(char *) "NOTMATCH",	/* 267 */
	(char *) "MATCHOP",	/* 268 */
	(char *) "FINAL",	/* 269 */
	(char *) "DOT",	/* 270 */
	(char *) "ALL",	/* 271 */
	(char *) "CCL",	/* 272 */
	(char *) "NCCL",	/* 273 */
	(char *) "CHAR",	/* 274 */
	(char *) "OR",	/* 275 */
	(char *) "STAR",	/* 276 */
	(char *) "QUEST",	/* 277 */
	(char *) "PLUS",	/* 278 */
	(char *) "EMPTYRE",	/* 279 */
	(char *) "IGNORE_PRIOR_ATOM",	/* 280 */
	(char *) "AND",	/* 281 */
	(char *) "BOR",	/* 282 */
	(char *) "APPEND",	/* 283 */
	(char *) "EQ",	/* 284 */
	(char *) "GE",	/* 285 */
	(char *) "GT",	/* 286 */
	(char *) "LE",	/* 287 */
	(char *) "LT",	/* 288 */
	(char *) "NE",	/* 289 */
	(char *) "IN",	/* 290 */
	(char *) "ARG",	/* 291 */
	(char *) "BLTIN",	/* 292 */
	(char *) "BREAK",	/* 293 */
	(char *) "CLOSE",	/* 294 */
	(char *) "CONTINUE",	/* 295 */
	(char *) "DELETE",	/* 296 */
	(char *) "DO",	/* 297 */
	(char *) "EXIT",	/* 298 */
	(char *) "FOR",	/* 299 */
	(char *) "FUNC",	/* 300 */
	(char *) "SUB",	/* 301 */
	(char *) "GSUB",	/* 302 */
	(char *) "IF",	/* 303 */
	(char *) "INDEX",	/* 304 */
	(char *) "LSUBSTR",	/* 305 */
	(char *) "MATCHFCN",	/* 306 */
	(char *) "NEXT",	/* 307 */
	(char *) "NEXTFILE",	/* 308 */
	(char *) "ADD",	/* 309 */
	(char *) "MINUS",	/* 310 */
	(char *) "MULT",	/* 311 */
	(char *) "DIVIDE",	/* 312 */
	(char *) "MOD",	/* 313 */
	(char *) "ASSIGN",	/* 314 */
	(char *) "ASGNOP",	/* 315 */
	(char *) "ADDEQ",	/* 316 */
	(char *) "SUBEQ",	/* 317 */
	(char *) "MULTEQ",	/* 318 */
	(char *) "DIVEQ",	/* 319 */
	(char *) "MODEQ",	/* 320 */
	(char *) "POWEQ",	/* 321 */
	(char *) "PRINT",	/* 322 */
	(char *) "PRINTF",	/* 323 */
	(char *) "SPRINTF",	/* 324 */
	(char *) "ELSE",	/* 325 */
	(char *) "INTEST",	/* 326 */
	(char *) "CONDEXPR",	/* 327 */
	(char *) "POSTINCR",	/* 328 */
	(char *) "PREINCR",	/* 329 */
	(char *) "POSTDECR",	/* 330 */
	(char *) "PREDECR",	/* 331 */
	(char *) "VAR",	/* 332 */
	(char *) "IVAR",	/* 333 */
	(char *) "VARNF",	/* 334 */
	(char *) "CALL",	/* 335 */
	(char *) "NUMBER",	/* 336 */
	(char *) "STRING",	/* 337 */
	(char *) "REGEXPR",	/* 338 */
	(char *) "GETLINE",	/* 339 */
	(char *) "SUBSTR",	/* 340 */
	(char *) "SPLIT",	/* 341 */
	(char *) "RETURN",	/* 342 */
	(char *) "WHILE",	/* 343 */
	(char *) "CAT",	/* 344 */
	(char *) "UPLUS",	/* 345 */
	(char *) "UMINUS",	/* 346 */
	(char *) "NOT",	/* 347 */
	(char *) "POWER",	/* 348 */
	(char *) "INCR",	/* 349 */
	(char *) "DECR",	/* 350 */
	(char *) "INDIRECT",	/* 351 */
	(char *) "LASTTOKEN",	/* 352 */
};


Cell *(*proctab[95])(Node **, int) = {
	nullproc,	/* FIRSTTOKEN */
	program,	/* PROGRAM */
	pastat,	/* PASTAT */
	dopa2,	/* PASTAT2 */
	nullproc,	/* XBEGIN */
	nullproc,	/* XEND */
	nullproc,	/* NL */
	array,	/* ARRAY */
	matchop,	/* MATCH */
	matchop,	/* NOTMATCH */
	nullproc,	/* MATCHOP */
	nullproc,	/* FINAL */
	nullproc,	/* DOT */
	nullproc,	/* ALL */
	nullproc,	/* CCL */
	nullproc,	/* NCCL */
	nullproc,	/* CHAR */
	nullproc,	/* OR */
	nullproc,	/* STAR */
	nullproc,	/* QUEST */
	nullproc,	/* PLUS */
	nullproc,	/* EMPTYRE */
	nullproc,	/* IGNORE_PRIOR_ATOM */
	boolop,	/* AND */
	boolop,	/* BOR */
	nullproc,	/* APPEND */
	relop,	/* EQ */
	relop,	/* GE */
	relop,	/* GT */
	relop,	/* LE */
	relop,	/* LT */
	relop,	/* NE */
	instat,	/* IN */
	arg,	/* ARG */
	bltin,	/* BLTIN */
	jump,	/* BREAK */
	closefile,	/* CLOSE */
	jump,	/* CONTINUE */
	awkdelete,	/* DELETE */
	dostat,	/* DO */
	jump,	/* EXIT */
	forstat,	/* FOR */
	nullproc,	/* FUNC */
	sub,	/* SUB */
	gsub,	/* GSUB */
	ifstat,	/* IF */
	sindex,	/* INDEX */
	nullproc,	/* LSUBSTR */
	matchop,	/* MATCHFCN */
	jump,	/* NEXT */
	jump,	/* NEXTFILE */
	arith,	/* ADD */
	arith,	/* MINUS */
	arith,	/* MULT */
	arith,	/* DIVIDE */
	arith,	/* MOD */
	assign,	/* ASSIGN */
	nullproc,	/* ASGNOP */
	assign,	/* ADDEQ */
	assign,	/* SUBEQ */
	assign,	/* MULTEQ */
	assign,	/* DIVEQ */
	assign,	/* MODEQ */
	assign,	/* POWEQ */
	printstat,	/* PRINT */
	awkprintf,	/* PRINTF */
	awksprintf,	/* SPRINTF */
	nullproc,	/* ELSE */
	intest,	/* INTEST */
	condexpr,	/* CONDEXPR */
	incrdecr,	/* POSTINCR */
	incrdecr,	/* PREINCR */
	incrdecr,	/* POSTDECR */
	incrdecr,	/* PREDECR */
	nullproc,	/* VAR */
	nullproc,	/* IVAR */
	getnf,	/* VARNF */
	call,	/* CALL */
	nullproc,	/* NUMBER */
	nullproc,	/* STRING */
	nullproc,	/* REGEXPR */
	awk_getline,	/* GETLINE */
	substr,	/* SUBSTR */
	split,	/* SPLIT */
	jump,	/* RETURN */
	whilestat,	/* WHILE */
	cat,	/* CAT */
	arith,	/* UPLUS */
	arith,	/* UMINUS */
	boolop,	/* NOT */
	arith,	/* POWER */
	nullproc,	/* INCR */
	nullproc,	/* DECR */
	indirect,	/* INDIRECT */
	nullproc,	/* LASTTOKEN */
};

char *tokname(int n)
{
	static char buf[100];

	if (n < FIRSTTOKEN || n > LASTTOKEN) {
		sprintf(buf, "token %d", n);
		return buf;
	}
	return printname[n-FIRSTTOKEN];
}
