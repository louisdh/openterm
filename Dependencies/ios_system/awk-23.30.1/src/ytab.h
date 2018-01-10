/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     FIRSTTOKEN = 258,
     PROGRAM = 259,
     PASTAT = 260,
     PASTAT2 = 261,
     XBEGIN = 262,
     XEND = 263,
     NL = 264,
     ARRAY = 265,
     MATCH = 266,
     NOTMATCH = 267,
     MATCHOP = 268,
     FINAL = 269,
     DOT = 270,
     ALL = 271,
     CCL = 272,
     NCCL = 273,
     CHAR = 274,
     OR = 275,
     STAR = 276,
     QUEST = 277,
     PLUS = 278,
     EMPTYRE = 279,
     IGNORE_PRIOR_ATOM = 280,
     AND = 281,
     BOR = 282,
     APPEND = 283,
     EQ = 284,
     GE = 285,
     GT = 286,
     LE = 287,
     LT = 288,
     NE = 289,
     IN = 290,
     ARG = 291,
     BLTIN = 292,
     BREAK = 293,
     CLOSE = 294,
     CONTINUE = 295,
     DELETE = 296,
     DO = 297,
     EXIT = 298,
     FOR = 299,
     FUNC = 300,
     SUB = 301,
     GSUB = 302,
     IF = 303,
     INDEX = 304,
     LSUBSTR = 305,
     MATCHFCN = 306,
     NEXT = 307,
     NEXTFILE = 308,
     ADD = 309,
     MINUS = 310,
     MULT = 311,
     DIVIDE = 312,
     MOD = 313,
     ASSIGN = 314,
     ASGNOP = 315,
     ADDEQ = 316,
     SUBEQ = 317,
     MULTEQ = 318,
     DIVEQ = 319,
     MODEQ = 320,
     POWEQ = 321,
     PRINT = 322,
     PRINTF = 323,
     SPRINTF = 324,
     ELSE = 325,
     INTEST = 326,
     CONDEXPR = 327,
     POSTINCR = 328,
     PREINCR = 329,
     POSTDECR = 330,
     PREDECR = 331,
     VAR = 332,
     IVAR = 333,
     VARNF = 334,
     CALL = 335,
     NUMBER = 336,
     STRING = 337,
     REGEXPR = 338,
     GETLINE = 339,
     SUBSTR = 340,
     SPLIT = 341,
     RETURN = 342,
     WHILE = 343,
     CAT = 344,
     UPLUS = 345,
     UMINUS = 346,
     NOT = 347,
     POWER = 348,
     INCR = 349,
     DECR = 350,
     INDIRECT = 351,
     LASTTOKEN = 352
   };
#endif
/* Tokens.  */
#define FIRSTTOKEN 258
#define PROGRAM 259
#define PASTAT 260
#define PASTAT2 261
#define XBEGIN 262
#define XEND 263
#define NL 264
#define ARRAY 265
#define MATCH 266
#define NOTMATCH 267
#define MATCHOP 268
#define FINAL 269
#define DOT 270
#define ALL 271
#define CCL 272
#define NCCL 273
#define CHAR 274
#define OR 275
#define STAR 276
#define QUEST 277
#define PLUS 278
#define EMPTYRE 279
#define IGNORE_PRIOR_ATOM 280
#define AND 281
#define BOR 282
#define APPEND 283
#define EQ 284
#define GE 285
#define GT 286
#define LE 287
#define LT 288
#define NE 289
#define IN 290
#define ARG 291
#define BLTIN 292
#define BREAK 293
#define CLOSE 294
#define CONTINUE 295
#define DELETE 296
#define DO 297
#define EXIT 298
#define FOR 299
#define FUNC 300
#define SUB 301
#define GSUB 302
#define IF 303
#define INDEX 304
#define LSUBSTR 305
#define MATCHFCN 306
#define NEXT 307
#define NEXTFILE 308
#define ADD 309
#define MINUS 310
#define MULT 311
#define DIVIDE 312
#define MOD 313
#define ASSIGN 314
#define ASGNOP 315
#define ADDEQ 316
#define SUBEQ 317
#define MULTEQ 318
#define DIVEQ 319
#define MODEQ 320
#define POWEQ 321
#define PRINT 322
#define PRINTF 323
#define SPRINTF 324
#define ELSE 325
#define INTEST 326
#define CONDEXPR 327
#define POSTINCR 328
#define PREINCR 329
#define POSTDECR 330
#define PREDECR 331
#define VAR 332
#define IVAR 333
#define VARNF 334
#define CALL 335
#define NUMBER 336
#define STRING 337
#define REGEXPR 338
#define GETLINE 339
#define SUBSTR 340
#define SPLIT 341
#define RETURN 342
#define WHILE 343
#define CAT 344
#define UPLUS 345
#define UMINUS 346
#define NOT 347
#define POWER 348
#define INCR 349
#define DECR 350
#define INDIRECT 351
#define LASTTOKEN 352




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 41 "awkgram.y"
{
	Node	*p;
	Cell	*cp;
	int	i;
	char	*s;
}
/* Line 1529 of yacc.c.  */
#line 250 "y.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

