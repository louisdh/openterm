/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C

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

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */
#include "ios_error.h"

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.3"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Using locations.  */
#define YYLSP_NEEDED 0



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




/* Copy the first part of user declarations.  */
#line 25 "awkgram.y"

#include <stdio.h>
#include <string.h>
#include "awk.h"

void checkdup(Node *list, Cell *item);
int yywrap(void) { return(1); }

__thread Node	*beginloc = 0;
__thread Node	*endloc = 0;
__thread int	infunc	= 0;	/* = 1 if in arglist or body of func */
__thread int	inloop	= 0;	/* = 1 if in while, for, do */
__thread char	*curfname = 0;	/* current function name */
__thread Node	*arglist = 0;	/* list of args for current function */


/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif

#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 41 "awkgram.y"
{
	Node	*p;
	Cell	*cp;
	int	i;
	char	*s;
}
/* Line 193 of yacc.c.  */
#line 313 "y.tab.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 326 "y.tab.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int i)
#else
static int
YYID (i)
    int i;
#endif
{
  return i;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  8
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   4787

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  114
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  49
/* YYNRULES -- Number of rules.  */
#define YYNRULES  186
/* YYNRULES -- Number of states.  */
#define YYNSTATES  369

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   352

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,   105,     2,     2,
      12,    16,   104,   102,     9,   103,     2,    15,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    95,    14,
       2,     2,     2,    94,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    18,     2,    19,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    11,    13,    17,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,    10,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    96,
      97,    98,    99,   100,   101,   106,   107,   108,   109,   110,
     111,   112,   113
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     5,     7,     9,    12,    14,    17,    19,
      22,    24,    27,    29,    32,    33,    46,    47,    58,    59,
      68,    70,    72,    77,    79,    82,    84,    87,    88,    90,
      91,    93,    94,    96,    98,   102,   104,   106,   111,   115,
     122,   126,   131,   136,   137,   147,   149,   153,   155,   159,
     163,   169,   173,   177,   181,   185,   189,   195,   198,   200,
     202,   206,   212,   216,   220,   224,   228,   232,   236,   240,
     244,   248,   252,   256,   262,   267,   271,   274,   276,   278,
     282,   286,   288,   292,   293,   295,   299,   301,   303,   305,
     307,   310,   313,   315,   318,   320,   323,   324,   329,   331,
     334,   339,   344,   349,   352,   358,   361,   363,   365,   367,
     370,   373,   376,   377,   378,   388,   392,   395,   397,   402,
     405,   409,   412,   415,   419,   422,   425,   426,   430,   433,
     435,   438,   440,   442,   447,   451,   455,   459,   463,   467,
     471,   475,   478,   481,   484,   488,   493,   495,   499,   504,
     507,   510,   513,   516,   519,   524,   528,   531,   533,   540,
     547,   551,   558,   565,   567,   576,   585,   592,   597,   599,
     606,   613,   622,   631,   640,   647,   649,   651,   656,   658,
     661,   662,   664,   668,   670,   672,   674
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
     115,     0,    -1,   132,    -1,     1,    -1,    36,    -1,   116,
      10,    -1,    37,    -1,   117,    10,    -1,     9,    -1,   118,
      10,    -1,    52,    -1,   119,    10,    -1,    80,    -1,   120,
      10,    -1,    -1,    54,    12,   131,    14,   129,   139,    14,
     129,   131,   149,   122,   152,    -1,    -1,    54,    12,   131,
      14,    14,   129,   131,   149,   123,   152,    -1,    -1,    54,
      12,   161,    45,   161,   149,   124,   152,    -1,    87,    -1,
      90,    -1,    58,    12,   139,   149,    -1,    11,    -1,   127,
      10,    -1,    10,    -1,   128,    10,    -1,    -1,   128,    -1,
      -1,   144,    -1,    -1,   150,    -1,   130,    -1,   130,   136,
     130,    -1,   139,    -1,   133,    -1,   133,   127,   156,    17,
      -1,   133,     9,   133,    -1,   133,     9,   133,   127,   156,
      17,    -1,   127,   156,    17,    -1,     7,   127,   156,    17,
      -1,     8,   127,   156,    17,    -1,    -1,    55,   125,    12,
     160,   149,   135,   127,   156,    17,    -1,   134,    -1,   136,
     130,   134,    -1,   139,    -1,   137,   118,   139,    -1,   159,
      70,   138,    -1,   138,    94,   138,    95,   138,    -1,   138,
     117,   138,    -1,   138,   116,   138,    -1,   138,    23,   147,
      -1,   138,    23,   138,    -1,   138,    45,   161,    -1,    12,
     140,    16,    45,   161,    -1,   138,   158,    -1,   146,    -1,
     158,    -1,   159,    70,   139,    -1,   139,    94,   139,    95,
     139,    -1,   139,   117,   139,    -1,   139,   116,   139,    -1,
     139,    39,   139,    -1,   139,    40,   139,    -1,   139,    41,
     139,    -1,   139,    42,   139,    -1,   139,    43,   139,    -1,
     139,    44,   139,    -1,   139,    23,   147,    -1,   139,    23,
     139,    -1,   139,    45,   161,    -1,    12,   140,    16,    45,
     161,    -1,   139,    13,    96,   159,    -1,   139,    13,    96,
      -1,   139,   158,    -1,   146,    -1,   158,    -1,   139,   118,
     139,    -1,   140,   118,   139,    -1,   138,    -1,   141,   118,
     138,    -1,    -1,   141,    -1,    12,   140,    16,    -1,    77,
      -1,    78,    -1,    10,    -1,    14,    -1,   144,    10,    -1,
     144,    14,    -1,    17,    -1,   145,    10,    -1,   147,    -1,
     108,   146,    -1,    -1,    15,   148,    93,    15,    -1,    16,
      -1,   149,    10,    -1,   143,   142,    13,   158,    -1,   143,
     142,    38,   158,    -1,   143,   142,    41,   158,    -1,   143,
     142,    -1,    51,   161,    18,   137,    19,    -1,    51,   161,
      -1,   139,    -1,     1,    -1,   128,    -1,    14,   129,    -1,
      48,   151,    -1,    50,   151,    -1,    -1,    -1,   119,   153,
     152,   154,   100,    12,   139,    16,   151,    -1,    53,   139,
     151,    -1,    53,   151,    -1,   121,    -1,   126,   152,   120,
     152,    -1,   126,   152,    -1,   127,   156,   145,    -1,    62,
     151,    -1,    63,   151,    -1,    99,   139,   151,    -1,    99,
     151,    -1,   150,   151,    -1,    -1,   162,   155,   152,    -1,
      14,   129,    -1,   152,    -1,   156,   152,    -1,    56,    -1,
      57,    -1,   158,    15,    70,   158,    -1,   158,   102,   158,
      -1,   158,   103,   158,    -1,   158,   104,   158,    -1,   158,
      15,   158,    -1,   146,    15,   158,    -1,   158,   105,   158,
      -1,   158,   109,   158,    -1,   103,   158,    -1,   102,   158,
      -1,   108,   158,    -1,    47,    12,    16,    -1,    47,    12,
     137,    16,    -1,    47,    -1,    90,    12,    16,    -1,    90,
      12,   137,    16,    -1,    49,   158,    -1,   111,   159,    -1,
     110,   159,    -1,   159,   111,    -1,   159,   110,    -1,    96,
     159,    43,   158,    -1,    96,    43,   158,    -1,    96,   159,
      -1,    96,    -1,    59,    12,   139,   118,   139,    16,    -1,
      59,    12,   139,   118,   147,    16,    -1,    12,   139,    16,
      -1,    61,    12,   139,   118,   147,    16,    -1,    61,    12,
     139,   118,   139,    16,    -1,    91,    -1,    98,    12,   139,
     118,   161,   118,   139,    16,    -1,    98,    12,   139,   118,
     161,   118,   147,    16,    -1,    98,    12,   139,   118,   161,
      16,    -1,    79,    12,   137,    16,    -1,    92,    -1,   157,
      12,   147,   118,   139,    16,    -1,   157,    12,   139,   118,
     139,    16,    -1,   157,    12,   147,   118,   139,   118,   159,
      16,    -1,   157,    12,   139,   118,   139,   118,   159,    16,
      -1,    97,    12,   139,   118,   139,   118,   139,    16,    -1,
      97,    12,   139,   118,   139,    16,    -1,   159,    -1,   161,
      -1,   161,    18,   137,    19,    -1,    88,    -1,   112,   158,
      -1,    -1,    87,    -1,   160,   118,    87,    -1,    87,    -1,
      46,    -1,    89,    -1,   100,    12,   139,   149,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,    98,    98,   100,   104,   104,   108,   108,   112,   112,
     116,   116,   120,   120,   124,   124,   126,   126,   128,   128,
     133,   134,   138,   142,   142,   146,   146,   150,   151,   155,
     156,   161,   162,   166,   167,   171,   175,   176,   177,   178,
     179,   180,   182,   184,   184,   189,   190,   194,   195,   199,
     200,   202,   204,   206,   207,   212,   213,   214,   215,   216,
     220,   221,   223,   225,   227,   228,   229,   230,   231,   232,
     233,   234,   239,   240,   241,   244,   247,   248,   249,   253,
     254,   258,   259,   263,   264,   265,   269,   269,   273,   273,
     273,   273,   277,   277,   281,   283,   287,   287,   291,   291,
     295,   298,   301,   304,   305,   306,   307,   308,   312,   313,
     317,   319,   321,   321,   321,   323,   324,   325,   326,   327,
     328,   329,   332,   335,   336,   337,   338,   338,   339,   343,
     344,   348,   348,   352,   353,   354,   355,   356,   357,   358,
     359,   360,   361,   362,   363,   364,   365,   366,   367,   368,
     369,   370,   371,   372,   373,   374,   375,   376,   377,   379,
     382,   383,   385,   390,   391,   393,   395,   397,   398,   399,
     401,   406,   408,   413,   415,   417,   421,   422,   423,   424,
     428,   429,   430,   436,   437,   438,   443
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "FIRSTTOKEN", "PROGRAM", "PASTAT",
  "PASTAT2", "XBEGIN", "XEND", "','", "NL", "'{'", "'('", "'|'", "';'",
  "'/'", "')'", "'}'", "'['", "']'", "ARRAY", "MATCH", "NOTMATCH",
  "MATCHOP", "FINAL", "DOT", "ALL", "CCL", "NCCL", "CHAR", "OR", "STAR",
  "QUEST", "PLUS", "EMPTYRE", "IGNORE_PRIOR_ATOM", "AND", "BOR", "APPEND",
  "EQ", "GE", "GT", "LE", "LT", "NE", "IN", "ARG", "BLTIN", "BREAK",
  "CLOSE", "CONTINUE", "DELETE", "DO", "EXIT", "FOR", "FUNC", "SUB",
  "GSUB", "IF", "INDEX", "LSUBSTR", "MATCHFCN", "NEXT", "NEXTFILE", "ADD",
  "MINUS", "MULT", "DIVIDE", "MOD", "ASSIGN", "ASGNOP", "ADDEQ", "SUBEQ",
  "MULTEQ", "DIVEQ", "MODEQ", "POWEQ", "PRINT", "PRINTF", "SPRINTF",
  "ELSE", "INTEST", "CONDEXPR", "POSTINCR", "PREINCR", "POSTDECR",
  "PREDECR", "VAR", "IVAR", "VARNF", "CALL", "NUMBER", "STRING", "REGEXPR",
  "'?'", "':'", "GETLINE", "SUBSTR", "SPLIT", "RETURN", "WHILE", "CAT",
  "'+'", "'-'", "'*'", "'%'", "UPLUS", "UMINUS", "NOT", "POWER", "INCR",
  "DECR", "INDIRECT", "LASTTOKEN", "$accept", "program", "and", "bor",
  "comma", "do", "else", "for", "@1", "@2", "@3", "funcname", "if",
  "lbrace", "nl", "opt_nl", "opt_pst", "opt_simple_stmt", "pas", "pa_pat",
  "pa_stat", "@4", "pa_stats", "patlist", "ppattern", "pattern", "plist",
  "pplist", "prarg", "print", "pst", "rbrace", "re", "reg_expr", "@5",
  "rparen", "simple_stmt", "st", "stmt", "@6", "@7", "@8", "stmtlist",
  "subop", "term", "var", "varlist", "varname", "while", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,    44,
     264,   123,    40,   124,    59,    47,    41,   125,    91,    93,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   313,   314,
     315,   316,   317,   318,   319,   320,   321,   322,   323,   324,
     325,   326,   327,   328,   329,   330,   331,   332,   333,   334,
     335,   336,   337,   338,    63,    58,   339,   340,   341,   342,
     343,   344,    43,    45,    42,    37,   345,   346,   347,   348,
     349,   350,   351,   352
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,   114,   115,   115,   116,   116,   117,   117,   118,   118,
     119,   119,   120,   120,   122,   121,   123,   121,   124,   121,
     125,   125,   126,   127,   127,   128,   128,   129,   129,   130,
     130,   131,   131,   132,   132,   133,   134,   134,   134,   134,
     134,   134,   134,   135,   134,   136,   136,   137,   137,   138,
     138,   138,   138,   138,   138,   138,   138,   138,   138,   138,
     139,   139,   139,   139,   139,   139,   139,   139,   139,   139,
     139,   139,   139,   139,   139,   139,   139,   139,   139,   140,
     140,   141,   141,   142,   142,   142,   143,   143,   144,   144,
     144,   144,   145,   145,   146,   146,   148,   147,   149,   149,
     150,   150,   150,   150,   150,   150,   150,   150,   151,   151,
     152,   152,   153,   154,   152,   152,   152,   152,   152,   152,
     152,   152,   152,   152,   152,   152,   155,   152,   152,   156,
     156,   157,   157,   158,   158,   158,   158,   158,   158,   158,
     158,   158,   158,   158,   158,   158,   158,   158,   158,   158,
     158,   158,   158,   158,   158,   158,   158,   158,   158,   158,
     158,   158,   158,   158,   158,   158,   158,   158,   158,   158,
     158,   158,   158,   158,   158,   158,   159,   159,   159,   159,
     160,   160,   160,   161,   161,   161,   162
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     1,     1,     1,     2,     1,     2,     1,     2,
       1,     2,     1,     2,     0,    12,     0,    10,     0,     8,
       1,     1,     4,     1,     2,     1,     2,     0,     1,     0,
       1,     0,     1,     1,     3,     1,     1,     4,     3,     6,
       3,     4,     4,     0,     9,     1,     3,     1,     3,     3,
       5,     3,     3,     3,     3,     3,     5,     2,     1,     1,
       3,     5,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     5,     4,     3,     2,     1,     1,     3,
       3,     1,     3,     0,     1,     3,     1,     1,     1,     1,
       2,     2,     1,     2,     1,     2,     0,     4,     1,     2,
       4,     4,     4,     2,     5,     2,     1,     1,     1,     2,
       2,     2,     0,     0,     9,     3,     2,     1,     4,     2,
       3,     2,     2,     3,     2,     2,     0,     3,     2,     1,
       2,     1,     1,     4,     3,     3,     3,     3,     3,     3,
       3,     2,     2,     2,     3,     4,     1,     3,     4,     2,
       2,     2,     2,     2,     4,     3,     2,     1,     6,     6,
       3,     6,     6,     1,     8,     8,     6,     4,     1,     6,
       6,     8,     8,     8,     6,     1,     1,     4,     1,     2,
       0,     1,     3,     1,     1,     1,     4
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,     3,    88,    89,     0,    33,     2,    30,     1,     0,
       0,    23,     0,    96,   184,   146,     0,     0,   131,   132,
       0,     0,     0,   183,   178,   185,     0,   163,   168,   157,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    36,
      45,    29,    35,    77,    94,     0,    78,   175,   176,    90,
      91,     0,     0,     0,     0,     0,     0,     0,     0,   149,
     175,    20,    21,     0,     0,     0,     0,     0,     0,   156,
       0,     0,   142,   141,    95,   143,   151,   150,   179,   107,
      24,    27,     0,     0,     0,    10,     0,     0,     0,     0,
       0,    86,    87,     0,     0,   112,   117,     0,     0,   106,
      83,     0,   129,     0,   126,     0,     0,    34,     0,     0,
       4,     6,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    76,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   153,   152,     0,     0,     0,     8,   160,     0,
       0,     0,     0,   144,     0,    47,     0,   180,     0,     0,
       0,   147,     0,   155,     0,     0,     0,    25,    28,   128,
      27,   108,   110,   111,   105,     0,   116,     0,     0,   121,
     122,     0,   124,     0,    11,     0,   119,     0,     0,    81,
      84,   103,    58,    59,   175,   125,    40,   130,     0,    38,
       0,    46,    75,    71,    70,    64,    65,    66,    67,    68,
      69,    72,     0,     5,    63,     7,    62,   138,     0,    94,
       0,   137,   134,   135,   136,   139,   140,    60,     0,    41,
      42,     9,    79,     0,    80,    97,   145,     0,   181,     0,
       0,     0,   167,   148,   154,     0,     0,    26,   109,     0,
     115,     0,    32,   176,     0,   123,     0,   113,    12,     0,
      92,   120,     0,     0,     0,     0,     0,     0,    57,     0,
       0,     0,     0,     0,   127,     0,    37,    74,     0,     0,
       0,   133,   177,    73,    48,    98,     0,    43,     0,    94,
       0,    94,     0,     0,     0,    27,     0,    22,   186,     0,
      13,   118,    93,    85,     0,    54,    53,    55,     0,    52,
      51,    82,   100,   101,   102,    49,     0,    61,     0,     0,
     182,    99,     0,   158,   159,   162,   161,   174,     0,   166,
       0,   104,    27,     0,     0,     0,     0,     0,     0,    39,
     170,     0,   169,     0,     0,     0,     0,    94,     0,     0,
      18,     0,    56,     0,    50,     0,     0,     0,   173,   164,
     165,     0,    27,     0,     0,   172,   171,    44,    16,     0,
      19,     0,     0,     0,   114,    17,    14,     0,    15
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     4,   120,   121,   227,    95,   249,    96,   367,   362,
     353,    63,    97,    98,   161,   159,     5,   241,     6,    39,
      40,   312,    41,   144,   179,    99,    54,   180,   181,   100,
       7,   251,    43,    44,    55,   277,   101,   162,   102,   175,
     289,   188,   103,    45,    46,    47,   229,    48,   104
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -327
static const yytype_int16 yypact[] =
{
     744,  -327,  -327,  -327,    48,  1663,  -327,    30,  -327,    51,
      51,  -327,  4501,  -327,  -327,    45,  4559,   -55,  -327,  -327,
      56,    59,    65,  -327,  -327,  -327,    94,  -327,  -327,   164,
     108,   111,  4559,  4559,  4559,   185,   185,  4559,   847,    79,
    -327,    77,  3663,   116,  -327,   113,    -7,   -32,   118,  -327,
    -327,   847,   847,  1767,   106,   -30,  4267,  4501,   116,    -7,
     -87,  -327,  -327,   122,  4501,  4501,  4501,  4325,  4559,    99,
    4501,  4501,    37,    37,  -327,    37,  -327,  -327,  -327,  -327,
    -327,   138,    91,    91,   -40,  -327,  2332,   142,   147,    91,
      91,  -327,  -327,  2332,   158,   163,  -327,  1469,   847,  3663,
    4617,    91,  -327,   916,  -327,  4501,   847,  1663,    95,  4501,
    -327,  -327,  4501,  4501,  4501,  4501,  4501,  4501,   -40,  4501,
    2390,  2448,    -7,  4559,  4501,  4383,  4559,  4559,  4559,  4559,
    4559,  4501,  -327,  -327,  4501,   985,  1054,  -327,  -327,  2506,
     130,  2506,   172,  -327,   110,  3663,  2781,   112,  2171,  2171,
     128,  -327,   149,    -7,  4559,  2171,  2171,  -327,   190,  -327,
     138,   190,  -327,  -327,   177,  2274,  -327,  1537,  4501,  -327,
    -327,  2274,  -327,  4501,  -327,  1469,   123,  1123,  4501,  4079,
     195,    15,   116,    -7,   -29,  -327,  -327,  -327,  1469,    51,
    1192,  -327,   185,  3939,  -327,  3939,  3939,  3939,  3939,  3939,
    3939,  -327,  2873,  -327,  3847,  -327,  3755,    37,  2171,   195,
    4559,    37,    -1,    -1,    37,    37,    37,  3663,    46,  -327,
    -327,  -327,  3663,   -40,  3663,  -327,  -327,  2506,  -327,   155,
    2506,  2506,  -327,  -327,    -7,  2506,    54,  -327,  -327,  4501,
    -327,   210,  -327,    16,  2974,  -327,  2974,  -327,  -327,  1262,
    -327,   215,   169,  4675,   -40,  4675,  2564,  2622,    -7,  2680,
    4559,  4559,  4559,  4675,  -327,   847,  -327,  -327,  4501,  2506,
    2506,    -7,  -327,  -327,  3663,  -327,    12,   216,  3075,   213,
    3176,   217,  1871,   196,    66,   146,   -40,   216,   216,   135,
    -327,  -327,  -327,   187,  4501,  4443,  -327,  -327,  4009,  4209,
    4149,  4079,    -7,    -7,    -7,  4079,  1331,  3663,  1975,  2079,
    -327,  -327,    51,  -327,  -327,  -327,  -327,  -327,  2506,  -327,
    2506,  -327,   138,  4501,   220,   226,   -40,   211,  4675,  -327,
    -327,     5,  -327,     5,   847,  3277,  3378,   238,  1605,  3470,
     216,  4501,  -327,   187,  4079,   239,   241,  1400,  -327,  -327,
    -327,   220,   138,  1469,  3571,  -327,  -327,  -327,   216,  1605,
    -327,    91,  1469,   220,  -327,  -327,   216,  1469,  -327
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -327,  -327,  -148,   152,    13,  -327,  -327,  -327,  -327,  -327,
    -327,  -327,  -327,    20,   -74,  -150,   218,  -326,  -327,   156,
     153,  -327,  -327,   -65,  -183,   550,  -173,  -327,  -327,  -327,
    -327,  -327,   181,   -64,  -327,  -235,  -140,   -47,   395,  -327,
    -327,  -327,   -48,  -327,   378,   -16,  -327,   132,  -327
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -32
static const yytype_int16 yytable[] =
{
      60,   150,   152,   135,   136,   252,    14,   158,   125,   287,
     238,   288,   351,    69,   125,   221,    60,    60,    60,    76,
      77,    60,   221,   132,   133,    38,    60,   242,   260,    51,
      52,   256,    61,   363,   134,    62,   163,    60,   131,   166,
      49,   263,   169,   170,    50,   194,   172,    23,     8,    25,
     177,    14,    60,   261,   185,   137,   262,    56,   190,   106,
     209,   286,    11,   142,   221,   272,   139,   141,    64,   218,
     295,    65,   298,   299,   300,   137,   301,    66,   132,   133,
     305,   132,   133,    60,   184,   321,   158,     2,   105,   340,
      11,     3,    23,    24,    25,   126,   127,   128,   129,   310,
      14,   157,   130,   128,   129,   160,    67,    60,   130,    60,
      60,    60,    60,    60,    60,   137,   358,    37,   240,   137,
      70,   327,   140,    71,   245,   124,   226,    38,   366,    60,
      60,   123,    60,    60,   147,   323,   134,   137,    60,    60,
      60,    23,   154,    25,   232,   344,   130,   256,   157,    60,
     256,   256,   256,   256,   167,    60,   157,   256,   137,   168,
     322,   230,   231,    60,   137,   233,   279,   281,   235,   236,
     173,   275,   338,   174,   284,   223,   267,    60,   137,    60,
      60,    60,    60,    60,    60,   293,    60,   225,    60,   296,
      60,   192,    60,   259,    60,   239,   256,    58,   242,   228,
     237,    60,   359,   248,   137,   137,    60,    68,    60,   265,
      14,   158,   319,    58,    58,    74,   164,   306,    58,   242,
     137,   269,   270,    58,   285,   292,   311,   343,    60,   314,
      60,    14,   326,   316,    58,   325,   275,   184,   341,   184,
     184,   184,   276,   184,    60,    60,    60,   184,   158,    58,
     201,    23,    24,    25,   350,   355,   337,   356,    60,   107,
     191,   189,    60,     0,    60,   141,    60,     0,     0,     0,
       0,     0,    23,    24,    25,     0,    37,     0,   158,    60,
      58,   182,    60,    60,    60,    60,   347,     0,     0,    60,
       0,    60,    60,    60,     0,   318,   320,    37,     0,   243,
       0,     0,     0,     0,    58,     0,    58,    58,    58,    58,
      58,    58,   184,     0,   364,   345,     0,   346,     0,    60,
      60,   331,   333,    60,     0,     0,    58,    58,    60,    58,
      58,   257,   334,     0,     0,    58,    58,    58,    60,     0,
     141,     0,     0,     0,     0,     0,    58,     0,     0,     0,
       0,     0,    58,     0,     0,   273,     0,     0,     0,     0,
      58,     0,     0,     0,     0,     0,     0,     0,   283,     0,
       0,     0,     0,     0,    58,     0,    58,    58,    58,    58,
      58,    58,     0,    58,     0,    58,   297,    58,     0,    58,
       0,    58,     0,     0,    59,     0,     0,     0,    58,     0,
       0,     0,     0,    58,     0,    58,     0,     0,     0,     0,
      72,    73,    75,     0,     0,    78,     0,     0,   324,     0,
     122,     0,     0,     0,     0,    58,     0,    58,     0,     0,
       0,   122,     0,     0,   182,     0,   182,   182,   182,     0,
     182,    58,    58,    58,   182,     0,   153,   257,     0,     0,
     257,   257,   257,   257,     0,    58,     0,   257,   342,    58,
       0,    58,     0,    58,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    58,   122,   183,    58,
      58,    58,    58,     0,     0,     0,    58,     0,    58,    58,
      58,     0,   176,     0,     0,     0,   257,     0,   187,     0,
       0,   207,     0,   211,   212,   213,   214,   215,   216,   182,
       0,     0,     0,     0,     0,     0,    58,    58,     0,     0,
      58,     0,     0,   122,   122,    58,   122,   122,     0,     0,
     187,   187,   234,   122,   122,    58,     0,     0,     0,     0,
       0,     0,     0,   122,     0,     0,     0,     0,     0,   122,
       0,     0,     0,     0,     0,    42,     0,   258,     0,     0,
       0,     0,    53,     0,     0,     0,     0,     0,     0,     0,
     247,   122,   187,   122,   122,   122,   122,   122,   122,     0,
     122,     0,   122,   264,   122,   187,   122,     0,   271,     0,
       0,     0,     0,     0,     0,   122,     0,     0,     0,     0,
     122,     0,   122,     0,     0,     0,   145,   146,     0,     0,
       0,     0,     0,     0,   148,   149,   145,   145,     0,     0,
     155,   156,   122,     0,   122,     0,     0,     0,     0,     0,
       0,   183,     0,   183,   183,   183,   165,   183,   302,   303,
     304,   183,     0,   171,   291,     0,     0,     0,     0,     0,
       0,     0,   122,     0,     0,    42,   122,    42,   122,   193,
     122,     0,   195,   196,   197,   198,   199,   200,     0,   202,
     204,   206,     0,   258,   208,     0,   258,   258,   258,   258,
       0,   217,     0,   258,   145,   122,   122,   122,     0,   222,
       0,   224,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   187,     0,     0,     0,     0,   183,     0,     0,     0,
       0,     0,     0,   122,   122,     0,     0,   122,   244,     0,
       0,     0,   258,   246,     0,     0,     0,     0,    53,     0,
       0,     0,   122,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   187,     0,   -29,     1,     0,     0,   360,     0,
       0,   -29,   -29,     0,     2,   -29,   -29,   365,     3,   -29,
       0,     0,   368,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   274,     0,     0,
     278,   280,     0,     0,     0,   282,     0,     0,     0,   145,
     -29,   -29,     0,   -29,     0,     0,     0,     0,     0,   -29,
     -29,   -29,     0,   -29,     0,   -29,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   307,   308,
     309,     0,     0,   -29,     0,     0,     0,     0,     0,     0,
       0,   -29,   -29,   -29,   -29,   -29,   -29,     0,     0,     0,
     -29,   -29,   -29,     0,    53,     0,   -29,   -29,    79,     0,
       0,     0,   -29,     0,   -29,   -29,   -29,    80,    11,    12,
       0,    81,    13,     0,     0,     0,     0,     0,   335,     0,
     336,     0,     0,   339,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   354,     0,    14,    15,    82,    16,    83,    84,    85,
      86,    87,     0,    18,    19,    88,    20,     0,    21,    89,
      90,     0,     0,     0,     0,     0,     0,    79,     0,     0,
       0,     0,     0,     0,    91,    92,    22,    11,    12,     0,
      81,    13,     0,   186,    23,    24,    25,    26,    27,    28,
       0,     0,     0,    29,    30,    31,    93,    94,     0,    32,
      33,     0,     0,     0,     0,    34,     0,    35,    36,    37,
       0,     0,    14,    15,    82,    16,    83,    84,    85,    86,
      87,     0,    18,    19,    88,    20,     0,    21,    89,    90,
       0,     0,     0,     0,     0,     0,    79,     0,     0,     0,
       0,     0,     0,    91,    92,    22,    11,    12,     0,    81,
      13,     0,   219,    23,    24,    25,    26,    27,    28,     0,
       0,     0,    29,    30,    31,    93,    94,     0,    32,    33,
       0,     0,     0,     0,    34,     0,    35,    36,    37,     0,
       0,    14,    15,    82,    16,    83,    84,    85,    86,    87,
       0,    18,    19,    88,    20,     0,    21,    89,    90,     0,
       0,     0,     0,     0,     0,    79,     0,     0,     0,     0,
       0,     0,    91,    92,    22,    11,    12,     0,    81,    13,
       0,   220,    23,    24,    25,    26,    27,    28,     0,     0,
       0,    29,    30,    31,    93,    94,     0,    32,    33,     0,
       0,     0,     0,    34,     0,    35,    36,    37,     0,     0,
      14,    15,    82,    16,    83,    84,    85,    86,    87,     0,
      18,    19,    88,    20,     0,    21,    89,    90,     0,     0,
       0,     0,     0,     0,    79,     0,     0,     0,     0,     0,
       0,    91,    92,    22,    11,    12,     0,    81,    13,     0,
     250,    23,    24,    25,    26,    27,    28,     0,     0,     0,
      29,    30,    31,    93,    94,     0,    32,    33,     0,     0,
       0,     0,    34,     0,    35,    36,    37,     0,     0,    14,
      15,    82,    16,    83,    84,    85,    86,    87,     0,    18,
      19,    88,    20,     0,    21,    89,    90,     0,     0,     0,
       0,     0,     0,    79,     0,     0,     0,     0,     0,     0,
      91,    92,    22,    11,    12,     0,    81,    13,     0,   266,
      23,    24,    25,    26,    27,    28,     0,     0,     0,    29,
      30,    31,    93,    94,     0,    32,    33,     0,     0,     0,
       0,    34,     0,    35,    36,    37,     0,     0,    14,    15,
      82,    16,    83,    84,    85,    86,    87,     0,    18,    19,
      88,    20,     0,    21,    89,    90,     0,     0,     0,     0,
       0,     0,     0,    79,     0,     0,     0,     0,     0,    91,
      92,    22,   290,    11,    12,     0,    81,    13,     0,    23,
      24,    25,    26,    27,    28,     0,     0,     0,    29,    30,
      31,    93,    94,     0,    32,    33,     0,     0,     0,     0,
      34,     0,    35,    36,    37,     0,     0,     0,    14,    15,
      82,    16,    83,    84,    85,    86,    87,     0,    18,    19,
      88,    20,     0,    21,    89,    90,     0,     0,     0,     0,
       0,     0,    79,     0,     0,     0,     0,     0,     0,    91,
      92,    22,    11,    12,     0,    81,    13,     0,   329,    23,
      24,    25,    26,    27,    28,     0,     0,     0,    29,    30,
      31,    93,    94,     0,    32,    33,     0,     0,     0,     0,
      34,     0,    35,    36,    37,     0,     0,    14,    15,    82,
      16,    83,    84,    85,    86,    87,     0,    18,    19,    88,
      20,     0,    21,    89,    90,     0,     0,     0,     0,     0,
       0,    79,     0,     0,     0,     0,     0,     0,    91,    92,
      22,    11,    12,     0,    81,    13,     0,   357,    23,    24,
      25,    26,    27,    28,     0,     0,     0,    29,    30,    31,
      93,    94,     0,    32,    33,     0,     0,     0,     0,    34,
       0,    35,    36,    37,     0,     0,    14,    15,    82,    16,
      83,    84,    85,    86,    87,     0,    18,    19,    88,    20,
       0,    21,    89,    90,     0,     0,     0,     0,     0,     0,
      79,     0,     0,     0,     0,     0,     0,    91,    92,    22,
      11,    12,     0,    81,    13,     0,     0,    23,    24,    25,
      26,    27,    28,     0,     0,     0,    29,    30,    31,    93,
      94,     0,    32,    33,     0,     0,     0,     0,    34,     0,
      35,    36,    37,     0,     0,    14,    15,    82,    16,    83,
      84,    85,    86,    87,     0,    18,    19,    88,    20,     0,
      21,    89,    90,     0,     0,     0,     0,     0,    79,     0,
       0,     0,     0,     0,     0,     0,    91,    92,    22,    12,
       0,   -31,    13,     0,     0,     0,    23,    24,    25,    26,
      27,    28,     0,     0,     0,    29,    30,    31,    93,    94,
       0,    32,    33,     0,     0,     0,     0,    34,     0,    35,
      36,    37,     0,    14,    15,     0,    16,     0,    84,     0,
       0,     0,     0,    18,    19,     0,    20,     0,    21,     0,
       0,     0,     0,     0,     0,     0,    79,     0,     0,     0,
       0,     0,     0,     0,    91,    92,    22,    12,     0,     0,
      13,   -31,     0,     0,    23,    24,    25,    26,    27,    28,
       0,     0,     0,    29,    30,    31,     0,     0,     0,    32,
      33,     0,     0,     0,     0,    34,     0,    35,    36,    37,
       0,    14,    15,     0,    16,     0,    84,     0,     0,     0,
       0,    18,    19,     0,    20,     0,    21,     0,     0,     0,
       9,    10,     0,     0,    11,    12,     0,     0,    13,     0,
       0,     0,    91,    92,    22,     0,     0,     0,     0,     0,
       0,     0,    23,    24,    25,    26,    27,    28,     0,     0,
       0,    29,    30,    31,     0,     0,     0,    32,    33,    14,
      15,     0,    16,    34,     0,    35,    36,    37,    17,    18,
      19,     0,    20,     0,    21,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    22,     0,     0,     0,     0,     0,     0,     0,
      23,    24,    25,    26,    27,    28,     0,     0,     0,    29,
      30,    31,     0,     0,     0,    32,    33,     0,     0,     0,
       0,    34,     0,    35,    36,    37,   137,     0,     0,    57,
     108,     0,    13,   138,     0,     0,     0,     0,     0,     0,
     109,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   110,   111,     0,   112,   113,   114,   115,
     116,   117,   118,    14,    15,     0,    16,     0,     0,     0,
       0,     0,     0,    18,    19,     0,    20,     0,    21,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    22,     0,     0,     0,
       0,     0,     0,     0,    23,    24,    25,    26,    27,    28,
       0,   119,     0,    29,    30,    31,     0,     0,     0,    32,
      33,     0,     0,     0,     0,    34,     0,    35,    36,    37,
     137,     0,     0,    57,   108,     0,    13,   317,     0,     0,
       0,     0,     0,     0,   109,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   110,   111,     0,
     112,   113,   114,   115,   116,   117,   118,    14,    15,     0,
      16,     0,     0,     0,     0,     0,     0,    18,    19,     0,
      20,     0,    21,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      22,     0,     0,     0,     0,     0,     0,     0,    23,    24,
      25,    26,    27,    28,     0,   119,     0,    29,    30,    31,
       0,     0,     0,    32,    33,     0,     0,     0,     0,    34,
       0,    35,    36,    37,   137,     0,     0,    57,   108,     0,
      13,   330,     0,     0,     0,     0,     0,     0,   109,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   110,   111,     0,   112,   113,   114,   115,   116,   117,
     118,    14,    15,     0,    16,     0,     0,     0,     0,     0,
       0,    18,    19,     0,    20,     0,    21,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    22,     0,     0,     0,     0,     0,
       0,     0,    23,    24,    25,    26,    27,    28,     0,   119,
       0,    29,    30,    31,     0,     0,     0,    32,    33,     0,
       0,     0,     0,    34,     0,    35,    36,    37,   137,     0,
       0,    57,   108,     0,    13,   332,     0,     0,     0,     0,
       0,     0,   109,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   110,   111,     0,   112,   113,
     114,   115,   116,   117,   118,    14,    15,     0,    16,     0,
       0,     0,     0,     0,     0,    18,    19,     0,    20,     0,
      21,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    22,     0,
       0,     0,     0,     0,     0,     0,    23,    24,    25,    26,
      27,    28,     0,   119,     0,    29,    30,    31,     0,     0,
     137,    32,    33,    57,   108,     0,    13,    34,     0,    35,
      36,    37,     0,     0,   109,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   110,   111,     0,
     112,   113,   114,   115,   116,   117,   118,    14,    15,     0,
      16,     0,     0,     0,     0,     0,     0,    18,    19,     0,
      20,     0,    21,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      22,     0,     0,     0,     0,     0,     0,     0,    23,    24,
      25,    26,    27,    28,     0,   119,     0,    29,    30,    31,
       0,     0,     0,    32,    33,     0,     0,     0,     0,    34,
       0,    35,    36,    37,   157,     0,    57,   108,   160,    13,
       0,     0,     0,     0,     0,     0,     0,   109,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     110,   111,     0,   112,   113,   114,   115,   116,   117,   118,
      14,    15,     0,    16,     0,     0,     0,     0,     0,     0,
      18,    19,     0,    20,     0,    21,     0,     0,     0,     0,
       0,     0,   157,     0,    12,     0,   160,    13,     0,     0,
       0,     0,     0,    22,     0,     0,     0,     0,     0,     0,
       0,    23,    24,    25,    26,    27,    28,     0,   119,     0,
      29,    30,    31,     0,     0,     0,    32,    33,    14,    15,
       0,    16,    34,     0,    35,    36,    37,     0,    18,    19,
       0,    20,     0,    21,     0,     0,     0,     0,     0,     0,
     203,     0,    12,     0,     0,    13,     0,     0,     0,     0,
       0,    22,     0,     0,     0,     0,     0,     0,     0,    23,
      24,    25,    26,    27,    28,     0,     0,     0,    29,    30,
      31,     0,     0,     0,    32,    33,    14,    15,     0,    16,
      34,     0,    35,    36,    37,     0,    18,    19,     0,    20,
       0,    21,     0,     0,     0,     0,     0,     0,   205,     0,
      12,     0,     0,    13,     0,     0,     0,     0,     0,    22,
       0,     0,     0,     0,     0,     0,     0,    23,    24,    25,
      26,    27,    28,     0,     0,     0,    29,    30,    31,     0,
       0,     0,    32,    33,    14,    15,     0,    16,    34,     0,
      35,    36,    37,     0,    18,    19,     0,    20,     0,    21,
       0,     0,     0,     0,     0,     0,   221,     0,    12,     0,
       0,    13,     0,     0,     0,     0,     0,    22,     0,     0,
       0,     0,     0,     0,     0,    23,    24,    25,    26,    27,
      28,     0,     0,     0,    29,    30,    31,     0,     0,     0,
      32,    33,    14,    15,     0,    16,    34,     0,    35,    36,
      37,     0,    18,    19,     0,    20,     0,    21,     0,     0,
       0,     0,     0,     0,   203,     0,   294,     0,     0,    13,
       0,     0,     0,     0,     0,    22,     0,     0,     0,     0,
       0,     0,     0,    23,    24,    25,    26,    27,    28,     0,
       0,     0,    29,    30,    31,     0,     0,     0,    32,    33,
      14,    15,     0,    16,    34,     0,    35,    36,    37,     0,
      18,    19,     0,    20,     0,    21,     0,     0,     0,     0,
       0,     0,   205,     0,   294,     0,     0,    13,     0,     0,
       0,     0,     0,    22,     0,     0,     0,     0,     0,     0,
       0,    23,    24,    25,    26,    27,    28,     0,     0,     0,
      29,    30,    31,     0,     0,     0,    32,    33,    14,    15,
       0,    16,    34,     0,    35,    36,    37,     0,    18,    19,
       0,    20,     0,    21,     0,     0,     0,     0,     0,     0,
     221,     0,   294,     0,     0,    13,     0,     0,     0,     0,
       0,    22,     0,     0,     0,     0,     0,     0,     0,    23,
      24,    25,    26,    27,    28,     0,     0,     0,    29,    30,
      31,     0,     0,     0,    32,    33,    14,    15,     0,    16,
      34,     0,    35,    36,    37,     0,    18,    19,     0,    20,
       0,    21,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    22,
       0,     0,     0,     0,     0,     0,     0,    23,    24,    25,
      26,    27,    28,     0,     0,     0,    29,    30,    31,     0,
       0,     0,    32,    33,     0,     0,     0,     0,    34,     0,
      35,    36,    37,    57,   108,     0,    13,   138,     0,     0,
       0,     0,     0,     0,   109,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   110,   111,     0,
     112,   113,   114,   115,   116,   117,   118,    14,    15,     0,
      16,     0,     0,     0,     0,     0,     0,    18,    19,     0,
      20,     0,    21,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      22,     0,     0,     0,     0,     0,     0,     0,    23,    24,
      25,    26,    27,    28,     0,   119,     0,    29,    30,    31,
       0,     0,     0,    32,    33,    57,   108,     0,    13,    34,
       0,    35,    36,    37,     0,     0,   109,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   110,
     111,     0,   112,   113,   114,   115,   116,   117,   118,    14,
      15,     0,    16,     0,     0,     0,     0,     0,     0,    18,
      19,     0,    20,     0,    21,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    22,     0,     0,     0,     0,     0,     0,     0,
      23,    24,    25,    26,    27,    28,     0,   119,   268,    29,
      30,    31,     0,     0,     0,    32,    33,     0,     0,     0,
       0,    34,     0,    35,    36,    37,    57,   108,     0,    13,
     275,     0,     0,     0,     0,     0,     0,   109,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     110,   111,     0,   112,   113,   114,   115,   116,   117,   118,
      14,    15,     0,    16,     0,     0,     0,     0,     0,     0,
      18,    19,     0,    20,     0,    21,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    22,     0,     0,     0,     0,     0,     0,
       0,    23,    24,    25,    26,    27,    28,     0,   119,     0,
      29,    30,    31,     0,     0,     0,    32,    33,     0,     0,
       0,     0,    34,     0,    35,    36,    37,    57,   108,     0,
      13,   313,     0,     0,     0,     0,     0,     0,   109,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   110,   111,     0,   112,   113,   114,   115,   116,   117,
     118,    14,    15,     0,    16,     0,     0,     0,     0,     0,
       0,    18,    19,     0,    20,     0,    21,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    22,     0,     0,     0,     0,     0,
       0,     0,    23,    24,    25,    26,    27,    28,     0,   119,
       0,    29,    30,    31,     0,     0,     0,    32,    33,     0,
       0,     0,     0,    34,     0,    35,    36,    37,    57,   108,
       0,    13,   315,     0,     0,     0,     0,     0,     0,   109,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   110,   111,     0,   112,   113,   114,   115,   116,
     117,   118,    14,    15,     0,    16,     0,     0,     0,     0,
       0,     0,    18,    19,     0,    20,     0,    21,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    22,     0,     0,     0,     0,
       0,     0,     0,    23,    24,    25,    26,    27,    28,     0,
     119,     0,    29,    30,    31,     0,     0,     0,    32,    33,
       0,     0,     0,     0,    34,     0,    35,    36,    37,    57,
     108,     0,    13,   348,     0,     0,     0,     0,     0,     0,
     109,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   110,   111,     0,   112,   113,   114,   115,
     116,   117,   118,    14,    15,     0,    16,     0,     0,     0,
       0,     0,     0,    18,    19,     0,    20,     0,    21,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    22,     0,     0,     0,
       0,     0,     0,     0,    23,    24,    25,    26,    27,    28,
       0,   119,     0,    29,    30,    31,     0,     0,     0,    32,
      33,     0,     0,     0,     0,    34,     0,    35,    36,    37,
      57,   108,     0,    13,   349,     0,     0,     0,     0,     0,
       0,   109,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   110,   111,     0,   112,   113,   114,
     115,   116,   117,   118,    14,    15,     0,    16,     0,     0,
       0,     0,     0,     0,    18,    19,     0,    20,     0,    21,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    22,     0,     0,
       0,     0,     0,     0,     0,    23,    24,    25,    26,    27,
      28,     0,   119,     0,    29,    30,    31,     0,     0,     0,
      32,    33,    57,   108,   352,    13,    34,     0,    35,    36,
      37,     0,     0,   109,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   110,   111,     0,   112,
     113,   114,   115,   116,   117,   118,    14,    15,     0,    16,
       0,     0,     0,     0,     0,     0,    18,    19,     0,    20,
       0,    21,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    22,
       0,     0,     0,     0,     0,     0,     0,    23,    24,    25,
      26,    27,    28,     0,   119,     0,    29,    30,    31,     0,
       0,     0,    32,    33,     0,     0,     0,     0,    34,     0,
      35,    36,    37,    57,   108,     0,    13,   361,     0,     0,
       0,     0,     0,     0,   109,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   110,   111,     0,
     112,   113,   114,   115,   116,   117,   118,    14,    15,     0,
      16,     0,     0,     0,     0,     0,     0,    18,    19,     0,
      20,     0,    21,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      22,     0,     0,     0,     0,     0,     0,     0,    23,    24,
      25,    26,    27,    28,     0,   119,     0,    29,    30,    31,
       0,     0,     0,    32,    33,    57,   108,     0,    13,    34,
       0,    35,    36,    37,     0,     0,   109,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   110,
     111,     0,   112,   113,   114,   115,   116,   117,   118,    14,
      15,     0,    16,     0,     0,     0,     0,     0,     0,    18,
      19,     0,    20,     0,    21,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    22,     0,     0,     0,     0,     0,     0,     0,
      23,    24,    25,    26,    27,    28,     0,   119,     0,    29,
      30,    31,     0,     0,     0,    32,    33,    57,   108,     0,
      13,    34,     0,    35,    36,    37,     0,     0,   109,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   110,     0,     0,   112,   113,   114,   115,   116,   117,
     118,    14,    15,     0,    16,     0,     0,     0,     0,     0,
       0,    18,    19,     0,    20,     0,    21,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    22,     0,     0,     0,     0,     0,
       0,     0,    23,    24,    25,    26,    27,    28,     0,     0,
       0,    29,    30,    31,     0,     0,     0,    32,    33,    57,
     108,     0,    13,    34,     0,    35,    36,    37,     0,     0,
     109,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   112,   113,   114,   115,
     116,   117,   118,    14,    15,     0,    16,     0,     0,     0,
       0,     0,     0,    18,    19,     0,    20,     0,    21,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    22,     0,     0,     0,
       0,     0,     0,     0,    23,    24,    25,    26,    27,    28,
       0,     0,     0,    29,    30,    31,     0,     0,     0,    32,
      33,    57,   -32,     0,    13,    34,     0,    35,    36,    37,
       0,     0,   -32,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   -32,   -32,
     -32,   -32,   -32,   -32,   -32,    14,    15,     0,    16,     0,
       0,     0,     0,     0,     0,    18,    19,     0,    20,     0,
      21,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    22,     0,
       0,    57,     0,     0,    13,     0,    23,    24,    25,    26,
      27,    28,   253,     0,     0,     0,    30,    31,     0,     0,
       0,    32,    33,     0,     0,   110,   111,    34,     0,    35,
      36,    37,     0,     0,   254,    14,    15,     0,    16,     0,
       0,     0,     0,     0,     0,    18,    19,     0,    20,     0,
      21,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    22,     0,
       0,    57,     0,     0,    13,     0,    23,    24,    25,    26,
      27,    28,   253,   255,   328,    29,    30,    31,     0,     0,
       0,    32,    33,     0,     0,   110,   111,    34,     0,    35,
      36,    37,     0,     0,   254,    14,    15,     0,    16,     0,
       0,     0,     0,     0,     0,    18,    19,     0,    20,     0,
      21,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    22,     0,
       0,    57,     0,     0,    13,     0,    23,    24,    25,    26,
      27,    28,   253,   255,     0,    29,    30,    31,     0,     0,
       0,    32,    33,     0,     0,   110,     0,    34,     0,    35,
      36,    37,     0,     0,   254,    14,    15,     0,    16,     0,
       0,     0,     0,     0,     0,    18,    19,     0,    20,     0,
      21,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    57,     0,     0,    13,     0,     0,     0,    22,     0,
       0,     0,   253,     0,     0,     0,    23,    24,    25,    26,
      27,    28,     0,     0,     0,    29,    30,    31,     0,     0,
       0,    32,    33,     0,   254,    14,    15,    34,    16,    35,
      36,    37,     0,     0,     0,    18,    19,     0,    20,     0,
      21,     0,     0,     0,     0,     0,     0,     0,     0,    12,
       0,     0,    13,   143,     0,     0,     0,     0,    22,     0,
       0,     0,     0,     0,     0,     0,    23,    24,    25,    26,
      27,    28,     0,     0,     0,    29,    30,    31,     0,     0,
       0,    32,    33,    14,    15,     0,    16,    34,     0,    35,
      36,    37,     0,    18,    19,     0,    20,     0,    21,     0,
       0,     0,     0,     0,     0,     0,     0,    12,     0,     0,
      13,   151,     0,     0,     0,     0,    22,     0,     0,     0,
       0,     0,     0,     0,    23,    24,    25,    26,    27,    28,
       0,     0,     0,    29,    30,    31,     0,     0,     0,    32,
      33,    14,    15,     0,    16,    34,     0,    35,    36,    37,
       0,    18,    19,     0,    20,     0,    21,     0,     0,     0,
       0,     0,     0,     0,     0,    57,     0,     0,    13,     0,
       0,     0,     0,     0,    22,     0,     0,     0,     0,     0,
       0,     0,    23,    24,    25,    26,    27,    28,     0,     0,
       0,    29,    30,    31,     0,     0,     0,    32,    33,    14,
      15,     0,    16,    34,     0,    35,    36,    37,     0,    18,
      19,     0,    20,     0,    21,     0,     0,     0,     0,     0,
       0,     0,     0,   210,     0,    57,     0,     0,    13,     0,
       0,     0,    22,     0,     0,     0,   -32,     0,     0,     0,
      23,    24,    25,    26,    27,    28,     0,     0,     0,    29,
      30,    31,     0,     0,     0,    32,    33,     0,   -32,    14,
      15,    34,    16,    35,    36,    37,     0,     0,     0,    18,
      19,     0,    20,     0,    21,     0,     0,     0,     0,     0,
       0,     0,     0,    12,     0,     0,    13,     0,     0,     0,
       0,     0,    22,     0,     0,     0,     0,     0,     0,     0,
      23,    24,    25,    26,    27,    28,     0,     0,     0,     0,
      30,    31,     0,     0,     0,    32,    33,    14,    15,     0,
      16,    34,     0,    35,    36,    37,     0,    18,    19,     0,
      20,     0,    21,     0,     0,     0,     0,     0,     0,     0,
       0,    57,     0,     0,    13,     0,     0,     0,     0,     0,
      22,     0,     0,     0,     0,     0,     0,     0,    23,    24,
      25,    26,    27,    28,     0,     0,     0,    29,    30,    31,
       0,     0,     0,    32,    33,    14,    15,     0,    16,    34,
       0,    35,    36,    37,     0,    18,    19,     0,    20,     0,
      21,     0,     0,     0,     0,     0,     0,     0,     0,   178,
       0,     0,    13,     0,     0,     0,     0,     0,    22,     0,
       0,     0,     0,     0,     0,     0,    23,    24,    25,    26,
      27,    28,     0,     0,     0,    29,    30,    31,     0,     0,
       0,    32,    33,    14,    15,     0,    16,    34,     0,    35,
      36,    37,     0,    18,    19,     0,    20,     0,    21,     0,
       0,     0,     0,     0,     0,     0,     0,   294,     0,     0,
      13,     0,     0,     0,     0,     0,    22,     0,     0,     0,
       0,     0,     0,     0,    23,    24,    25,    26,    27,    28,
       0,     0,     0,    29,    30,    31,     0,     0,     0,    32,
      33,    14,    15,     0,    16,    34,     0,    35,    36,    37,
       0,    18,    19,     0,    20,     0,    21,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    22,     0,     0,     0,     0,     0,
       0,     0,    23,    24,    25,    26,    27,    28,     0,     0,
       0,    29,    30,    31,     0,     0,     0,    32,    33,     0,
       0,     0,     0,    34,     0,    35,    36,    37
};

static const yytype_int16 yycheck[] =
{
      16,    66,    67,    51,    52,   178,    46,    81,    15,   244,
     160,   246,   338,    29,    15,    10,    32,    33,    34,    35,
      36,    37,    10,   110,   111,     5,    42,   167,    13,     9,
      10,   179,    87,   359,    18,    90,    83,    53,    70,    86,
      10,    70,    89,    90,    14,   109,    93,    87,     0,    89,
      98,    46,    68,    38,   101,     9,    41,    12,   106,    39,
     124,    45,    11,    93,    10,    19,    53,    54,    12,   134,
     253,    12,   255,   256,   257,     9,   259,    12,   110,   111,
     263,   110,   111,    99,   100,    19,   160,    10,     9,   324,
      11,    14,    87,    88,    89,   102,   103,   104,   105,    87,
      46,    10,   109,   104,   105,    14,    12,   123,   109,   125,
     126,   127,   128,   129,   130,     9,   351,   112,   165,     9,
      12,   294,    16,    12,   171,    12,    16,   107,   363,   145,
     146,    15,   148,   149,    12,   285,    18,     9,   154,   155,
     156,    87,    43,    89,    16,   328,   109,   295,    10,   165,
     298,   299,   300,   301,    12,   171,    10,   305,     9,    12,
      14,   148,   149,   179,     9,    16,   230,   231,   155,   156,
      12,    16,   322,    10,   239,    45,   192,   193,     9,   195,
     196,   197,   198,   199,   200,    16,   202,    15,   204,   253,
     206,    96,   208,   180,   210,    18,   344,    16,   338,    87,
      10,   217,   352,    80,     9,     9,   222,    43,   224,   189,
      46,   285,    16,    32,    33,    34,    84,   265,    37,   359,
       9,   208,   209,    42,    14,    10,    10,    16,   244,    16,
     246,    46,    45,    16,    53,   100,    16,   253,    12,   255,
     256,   257,   229,   259,   260,   261,   262,   263,   322,    68,
     118,    87,    88,    89,    16,    16,   320,    16,   274,    41,
     107,   105,   278,    -1,   280,   252,   282,    -1,    -1,    -1,
      -1,    -1,    87,    88,    89,    -1,   112,    -1,   352,   295,
      99,   100,   298,   299,   300,   301,   334,    -1,    -1,   305,
      -1,   307,   308,   309,    -1,   282,   283,   112,    -1,   167,
      -1,    -1,    -1,    -1,   123,    -1,   125,   126,   127,   128,
     129,   130,   328,    -1,   361,   331,    -1,   333,    -1,   335,
     336,   308,   309,   339,    -1,    -1,   145,   146,   344,   148,
     149,   179,   312,    -1,    -1,   154,   155,   156,   354,    -1,
     327,    -1,    -1,    -1,    -1,    -1,   165,    -1,    -1,    -1,
      -1,    -1,   171,    -1,    -1,   223,    -1,    -1,    -1,    -1,
     179,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   236,    -1,
      -1,    -1,    -1,    -1,   193,    -1,   195,   196,   197,   198,
     199,   200,    -1,   202,    -1,   204,   254,   206,    -1,   208,
      -1,   210,    -1,    -1,    16,    -1,    -1,    -1,   217,    -1,
      -1,    -1,    -1,   222,    -1,   224,    -1,    -1,    -1,    -1,
      32,    33,    34,    -1,    -1,    37,    -1,    -1,   286,    -1,
      42,    -1,    -1,    -1,    -1,   244,    -1,   246,    -1,    -1,
      -1,    53,    -1,    -1,   253,    -1,   255,   256,   257,    -1,
     259,   260,   261,   262,   263,    -1,    68,   295,    -1,    -1,
     298,   299,   300,   301,    -1,   274,    -1,   305,   326,   278,
      -1,   280,    -1,   282,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   295,    99,   100,   298,
     299,   300,   301,    -1,    -1,    -1,   305,    -1,   307,   308,
     309,    -1,    97,    -1,    -1,    -1,   344,    -1,   103,    -1,
      -1,   123,    -1,   125,   126,   127,   128,   129,   130,   328,
      -1,    -1,    -1,    -1,    -1,    -1,   335,   336,    -1,    -1,
     339,    -1,    -1,   145,   146,   344,   148,   149,    -1,    -1,
     135,   136,   154,   155,   156,   354,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   165,    -1,    -1,    -1,    -1,    -1,   171,
      -1,    -1,    -1,    -1,    -1,     5,    -1,   179,    -1,    -1,
      -1,    -1,    12,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     175,   193,   177,   195,   196,   197,   198,   199,   200,    -1,
     202,    -1,   204,   188,   206,   190,   208,    -1,   210,    -1,
      -1,    -1,    -1,    -1,    -1,   217,    -1,    -1,    -1,    -1,
     222,    -1,   224,    -1,    -1,    -1,    56,    57,    -1,    -1,
      -1,    -1,    -1,    -1,    64,    65,    66,    67,    -1,    -1,
      70,    71,   244,    -1,   246,    -1,    -1,    -1,    -1,    -1,
      -1,   253,    -1,   255,   256,   257,    86,   259,   260,   261,
     262,   263,    -1,    93,   249,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   274,    -1,    -1,   105,   278,   107,   280,   109,
     282,    -1,   112,   113,   114,   115,   116,   117,    -1,   119,
     120,   121,    -1,   295,   124,    -1,   298,   299,   300,   301,
      -1,   131,    -1,   305,   134,   307,   308,   309,    -1,   139,
      -1,   141,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   306,    -1,    -1,    -1,    -1,   328,    -1,    -1,    -1,
      -1,    -1,    -1,   335,   336,    -1,    -1,   339,   168,    -1,
      -1,    -1,   344,   173,    -1,    -1,    -1,    -1,   178,    -1,
      -1,    -1,   354,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   347,    -1,     0,     1,    -1,    -1,   353,    -1,
      -1,     7,     8,    -1,    10,    11,    12,   362,    14,    15,
      -1,    -1,   367,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   227,    -1,    -1,
     230,   231,    -1,    -1,    -1,   235,    -1,    -1,    -1,   239,
      46,    47,    -1,    49,    -1,    -1,    -1,    -1,    -1,    55,
      56,    57,    -1,    59,    -1,    61,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   268,   269,
     270,    -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    87,    88,    89,    90,    91,    92,    -1,    -1,    -1,
      96,    97,    98,    -1,   294,    -1,   102,   103,     1,    -1,
      -1,    -1,   108,    -1,   110,   111,   112,    10,    11,    12,
      -1,    14,    15,    -1,    -1,    -1,    -1,    -1,   318,    -1,
     320,    -1,    -1,   323,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   341,    -1,    46,    47,    48,    49,    50,    51,    52,
      53,    54,    -1,    56,    57,    58,    59,    -1,    61,    62,
      63,    -1,    -1,    -1,    -1,    -1,    -1,     1,    -1,    -1,
      -1,    -1,    -1,    -1,    77,    78,    79,    11,    12,    -1,
      14,    15,    -1,    17,    87,    88,    89,    90,    91,    92,
      -1,    -1,    -1,    96,    97,    98,    99,   100,    -1,   102,
     103,    -1,    -1,    -1,    -1,   108,    -1,   110,   111,   112,
      -1,    -1,    46,    47,    48,    49,    50,    51,    52,    53,
      54,    -1,    56,    57,    58,    59,    -1,    61,    62,    63,
      -1,    -1,    -1,    -1,    -1,    -1,     1,    -1,    -1,    -1,
      -1,    -1,    -1,    77,    78,    79,    11,    12,    -1,    14,
      15,    -1,    17,    87,    88,    89,    90,    91,    92,    -1,
      -1,    -1,    96,    97,    98,    99,   100,    -1,   102,   103,
      -1,    -1,    -1,    -1,   108,    -1,   110,   111,   112,    -1,
      -1,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      -1,    56,    57,    58,    59,    -1,    61,    62,    63,    -1,
      -1,    -1,    -1,    -1,    -1,     1,    -1,    -1,    -1,    -1,
      -1,    -1,    77,    78,    79,    11,    12,    -1,    14,    15,
      -1,    17,    87,    88,    89,    90,    91,    92,    -1,    -1,
      -1,    96,    97,    98,    99,   100,    -1,   102,   103,    -1,
      -1,    -1,    -1,   108,    -1,   110,   111,   112,    -1,    -1,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    -1,
      56,    57,    58,    59,    -1,    61,    62,    63,    -1,    -1,
      -1,    -1,    -1,    -1,     1,    -1,    -1,    -1,    -1,    -1,
      -1,    77,    78,    79,    11,    12,    -1,    14,    15,    -1,
      17,    87,    88,    89,    90,    91,    92,    -1,    -1,    -1,
      96,    97,    98,    99,   100,    -1,   102,   103,    -1,    -1,
      -1,    -1,   108,    -1,   110,   111,   112,    -1,    -1,    46,
      47,    48,    49,    50,    51,    52,    53,    54,    -1,    56,
      57,    58,    59,    -1,    61,    62,    63,    -1,    -1,    -1,
      -1,    -1,    -1,     1,    -1,    -1,    -1,    -1,    -1,    -1,
      77,    78,    79,    11,    12,    -1,    14,    15,    -1,    17,
      87,    88,    89,    90,    91,    92,    -1,    -1,    -1,    96,
      97,    98,    99,   100,    -1,   102,   103,    -1,    -1,    -1,
      -1,   108,    -1,   110,   111,   112,    -1,    -1,    46,    47,
      48,    49,    50,    51,    52,    53,    54,    -1,    56,    57,
      58,    59,    -1,    61,    62,    63,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,     1,    -1,    -1,    -1,    -1,    -1,    77,
      78,    79,    10,    11,    12,    -1,    14,    15,    -1,    87,
      88,    89,    90,    91,    92,    -1,    -1,    -1,    96,    97,
      98,    99,   100,    -1,   102,   103,    -1,    -1,    -1,    -1,
     108,    -1,   110,   111,   112,    -1,    -1,    -1,    46,    47,
      48,    49,    50,    51,    52,    53,    54,    -1,    56,    57,
      58,    59,    -1,    61,    62,    63,    -1,    -1,    -1,    -1,
      -1,    -1,     1,    -1,    -1,    -1,    -1,    -1,    -1,    77,
      78,    79,    11,    12,    -1,    14,    15,    -1,    17,    87,
      88,    89,    90,    91,    92,    -1,    -1,    -1,    96,    97,
      98,    99,   100,    -1,   102,   103,    -1,    -1,    -1,    -1,
     108,    -1,   110,   111,   112,    -1,    -1,    46,    47,    48,
      49,    50,    51,    52,    53,    54,    -1,    56,    57,    58,
      59,    -1,    61,    62,    63,    -1,    -1,    -1,    -1,    -1,
      -1,     1,    -1,    -1,    -1,    -1,    -1,    -1,    77,    78,
      79,    11,    12,    -1,    14,    15,    -1,    17,    87,    88,
      89,    90,    91,    92,    -1,    -1,    -1,    96,    97,    98,
      99,   100,    -1,   102,   103,    -1,    -1,    -1,    -1,   108,
      -1,   110,   111,   112,    -1,    -1,    46,    47,    48,    49,
      50,    51,    52,    53,    54,    -1,    56,    57,    58,    59,
      -1,    61,    62,    63,    -1,    -1,    -1,    -1,    -1,    -1,
       1,    -1,    -1,    -1,    -1,    -1,    -1,    77,    78,    79,
      11,    12,    -1,    14,    15,    -1,    -1,    87,    88,    89,
      90,    91,    92,    -1,    -1,    -1,    96,    97,    98,    99,
     100,    -1,   102,   103,    -1,    -1,    -1,    -1,   108,    -1,
     110,   111,   112,    -1,    -1,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    -1,    56,    57,    58,    59,    -1,
      61,    62,    63,    -1,    -1,    -1,    -1,    -1,     1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    77,    78,    79,    12,
      -1,    14,    15,    -1,    -1,    -1,    87,    88,    89,    90,
      91,    92,    -1,    -1,    -1,    96,    97,    98,    99,   100,
      -1,   102,   103,    -1,    -1,    -1,    -1,   108,    -1,   110,
     111,   112,    -1,    46,    47,    -1,    49,    -1,    51,    -1,
      -1,    -1,    -1,    56,    57,    -1,    59,    -1,    61,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,     1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    77,    78,    79,    12,    -1,    -1,
      15,    16,    -1,    -1,    87,    88,    89,    90,    91,    92,
      -1,    -1,    -1,    96,    97,    98,    -1,    -1,    -1,   102,
     103,    -1,    -1,    -1,    -1,   108,    -1,   110,   111,   112,
      -1,    46,    47,    -1,    49,    -1,    51,    -1,    -1,    -1,
      -1,    56,    57,    -1,    59,    -1,    61,    -1,    -1,    -1,
       7,     8,    -1,    -1,    11,    12,    -1,    -1,    15,    -1,
      -1,    -1,    77,    78,    79,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    87,    88,    89,    90,    91,    92,    -1,    -1,
      -1,    96,    97,    98,    -1,    -1,    -1,   102,   103,    46,
      47,    -1,    49,   108,    -1,   110,   111,   112,    55,    56,
      57,    -1,    59,    -1,    61,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      87,    88,    89,    90,    91,    92,    -1,    -1,    -1,    96,
      97,    98,    -1,    -1,    -1,   102,   103,    -1,    -1,    -1,
      -1,   108,    -1,   110,   111,   112,     9,    -1,    -1,    12,
      13,    -1,    15,    16,    -1,    -1,    -1,    -1,    -1,    -1,
      23,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    36,    37,    -1,    39,    40,    41,    42,
      43,    44,    45,    46,    47,    -1,    49,    -1,    -1,    -1,
      -1,    -1,    -1,    56,    57,    -1,    59,    -1,    61,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    79,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    87,    88,    89,    90,    91,    92,
      -1,    94,    -1,    96,    97,    98,    -1,    -1,    -1,   102,
     103,    -1,    -1,    -1,    -1,   108,    -1,   110,   111,   112,
       9,    -1,    -1,    12,    13,    -1,    15,    16,    -1,    -1,
      -1,    -1,    -1,    -1,    23,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    36,    37,    -1,
      39,    40,    41,    42,    43,    44,    45,    46,    47,    -1,
      49,    -1,    -1,    -1,    -1,    -1,    -1,    56,    57,    -1,
      59,    -1,    61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,    88,
      89,    90,    91,    92,    -1,    94,    -1,    96,    97,    98,
      -1,    -1,    -1,   102,   103,    -1,    -1,    -1,    -1,   108,
      -1,   110,   111,   112,     9,    -1,    -1,    12,    13,    -1,
      15,    16,    -1,    -1,    -1,    -1,    -1,    -1,    23,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    36,    37,    -1,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    -1,    49,    -1,    -1,    -1,    -1,    -1,
      -1,    56,    57,    -1,    59,    -1,    61,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    87,    88,    89,    90,    91,    92,    -1,    94,
      -1,    96,    97,    98,    -1,    -1,    -1,   102,   103,    -1,
      -1,    -1,    -1,   108,    -1,   110,   111,   112,     9,    -1,
      -1,    12,    13,    -1,    15,    16,    -1,    -1,    -1,    -1,
      -1,    -1,    23,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    36,    37,    -1,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    -1,    49,    -1,
      -1,    -1,    -1,    -1,    -1,    56,    57,    -1,    59,    -1,
      61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    79,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    87,    88,    89,    90,
      91,    92,    -1,    94,    -1,    96,    97,    98,    -1,    -1,
       9,   102,   103,    12,    13,    -1,    15,   108,    -1,   110,
     111,   112,    -1,    -1,    23,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    36,    37,    -1,
      39,    40,    41,    42,    43,    44,    45,    46,    47,    -1,
      49,    -1,    -1,    -1,    -1,    -1,    -1,    56,    57,    -1,
      59,    -1,    61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,    88,
      89,    90,    91,    92,    -1,    94,    -1,    96,    97,    98,
      -1,    -1,    -1,   102,   103,    -1,    -1,    -1,    -1,   108,
      -1,   110,   111,   112,    10,    -1,    12,    13,    14,    15,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    23,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      36,    37,    -1,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    -1,    49,    -1,    -1,    -1,    -1,    -1,    -1,
      56,    57,    -1,    59,    -1,    61,    -1,    -1,    -1,    -1,
      -1,    -1,    10,    -1,    12,    -1,    14,    15,    -1,    -1,
      -1,    -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    87,    88,    89,    90,    91,    92,    -1,    94,    -1,
      96,    97,    98,    -1,    -1,    -1,   102,   103,    46,    47,
      -1,    49,   108,    -1,   110,   111,   112,    -1,    56,    57,
      -1,    59,    -1,    61,    -1,    -1,    -1,    -1,    -1,    -1,
      10,    -1,    12,    -1,    -1,    15,    -1,    -1,    -1,    -1,
      -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,
      88,    89,    90,    91,    92,    -1,    -1,    -1,    96,    97,
      98,    -1,    -1,    -1,   102,   103,    46,    47,    -1,    49,
     108,    -1,   110,   111,   112,    -1,    56,    57,    -1,    59,
      -1,    61,    -1,    -1,    -1,    -1,    -1,    -1,    10,    -1,
      12,    -1,    -1,    15,    -1,    -1,    -1,    -1,    -1,    79,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,    88,    89,
      90,    91,    92,    -1,    -1,    -1,    96,    97,    98,    -1,
      -1,    -1,   102,   103,    46,    47,    -1,    49,   108,    -1,
     110,   111,   112,    -1,    56,    57,    -1,    59,    -1,    61,
      -1,    -1,    -1,    -1,    -1,    -1,    10,    -1,    12,    -1,
      -1,    15,    -1,    -1,    -1,    -1,    -1,    79,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    87,    88,    89,    90,    91,
      92,    -1,    -1,    -1,    96,    97,    98,    -1,    -1,    -1,
     102,   103,    46,    47,    -1,    49,   108,    -1,   110,   111,
     112,    -1,    56,    57,    -1,    59,    -1,    61,    -1,    -1,
      -1,    -1,    -1,    -1,    10,    -1,    12,    -1,    -1,    15,
      -1,    -1,    -1,    -1,    -1,    79,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    87,    88,    89,    90,    91,    92,    -1,
      -1,    -1,    96,    97,    98,    -1,    -1,    -1,   102,   103,
      46,    47,    -1,    49,   108,    -1,   110,   111,   112,    -1,
      56,    57,    -1,    59,    -1,    61,    -1,    -1,    -1,    -1,
      -1,    -1,    10,    -1,    12,    -1,    -1,    15,    -1,    -1,
      -1,    -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    87,    88,    89,    90,    91,    92,    -1,    -1,    -1,
      96,    97,    98,    -1,    -1,    -1,   102,   103,    46,    47,
      -1,    49,   108,    -1,   110,   111,   112,    -1,    56,    57,
      -1,    59,    -1,    61,    -1,    -1,    -1,    -1,    -1,    -1,
      10,    -1,    12,    -1,    -1,    15,    -1,    -1,    -1,    -1,
      -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,
      88,    89,    90,    91,    92,    -1,    -1,    -1,    96,    97,
      98,    -1,    -1,    -1,   102,   103,    46,    47,    -1,    49,
     108,    -1,   110,   111,   112,    -1,    56,    57,    -1,    59,
      -1,    61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    79,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,    88,    89,
      90,    91,    92,    -1,    -1,    -1,    96,    97,    98,    -1,
      -1,    -1,   102,   103,    -1,    -1,    -1,    -1,   108,    -1,
     110,   111,   112,    12,    13,    -1,    15,    16,    -1,    -1,
      -1,    -1,    -1,    -1,    23,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    36,    37,    -1,
      39,    40,    41,    42,    43,    44,    45,    46,    47,    -1,
      49,    -1,    -1,    -1,    -1,    -1,    -1,    56,    57,    -1,
      59,    -1,    61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,    88,
      89,    90,    91,    92,    -1,    94,    -1,    96,    97,    98,
      -1,    -1,    -1,   102,   103,    12,    13,    -1,    15,   108,
      -1,   110,   111,   112,    -1,    -1,    23,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    36,
      37,    -1,    39,    40,    41,    42,    43,    44,    45,    46,
      47,    -1,    49,    -1,    -1,    -1,    -1,    -1,    -1,    56,
      57,    -1,    59,    -1,    61,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      87,    88,    89,    90,    91,    92,    -1,    94,    95,    96,
      97,    98,    -1,    -1,    -1,   102,   103,    -1,    -1,    -1,
      -1,   108,    -1,   110,   111,   112,    12,    13,    -1,    15,
      16,    -1,    -1,    -1,    -1,    -1,    -1,    23,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      36,    37,    -1,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    -1,    49,    -1,    -1,    -1,    -1,    -1,    -1,
      56,    57,    -1,    59,    -1,    61,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    87,    88,    89,    90,    91,    92,    -1,    94,    -1,
      96,    97,    98,    -1,    -1,    -1,   102,   103,    -1,    -1,
      -1,    -1,   108,    -1,   110,   111,   112,    12,    13,    -1,
      15,    16,    -1,    -1,    -1,    -1,    -1,    -1,    23,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    36,    37,    -1,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    -1,    49,    -1,    -1,    -1,    -1,    -1,
      -1,    56,    57,    -1,    59,    -1,    61,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    87,    88,    89,    90,    91,    92,    -1,    94,
      -1,    96,    97,    98,    -1,    -1,    -1,   102,   103,    -1,
      -1,    -1,    -1,   108,    -1,   110,   111,   112,    12,    13,
      -1,    15,    16,    -1,    -1,    -1,    -1,    -1,    -1,    23,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    36,    37,    -1,    39,    40,    41,    42,    43,
      44,    45,    46,    47,    -1,    49,    -1,    -1,    -1,    -1,
      -1,    -1,    56,    57,    -1,    59,    -1,    61,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    79,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    87,    88,    89,    90,    91,    92,    -1,
      94,    -1,    96,    97,    98,    -1,    -1,    -1,   102,   103,
      -1,    -1,    -1,    -1,   108,    -1,   110,   111,   112,    12,
      13,    -1,    15,    16,    -1,    -1,    -1,    -1,    -1,    -1,
      23,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    36,    37,    -1,    39,    40,    41,    42,
      43,    44,    45,    46,    47,    -1,    49,    -1,    -1,    -1,
      -1,    -1,    -1,    56,    57,    -1,    59,    -1,    61,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    79,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    87,    88,    89,    90,    91,    92,
      -1,    94,    -1,    96,    97,    98,    -1,    -1,    -1,   102,
     103,    -1,    -1,    -1,    -1,   108,    -1,   110,   111,   112,
      12,    13,    -1,    15,    16,    -1,    -1,    -1,    -1,    -1,
      -1,    23,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    36,    37,    -1,    39,    40,    41,
      42,    43,    44,    45,    46,    47,    -1,    49,    -1,    -1,
      -1,    -1,    -1,    -1,    56,    57,    -1,    59,    -1,    61,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    79,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    87,    88,    89,    90,    91,
      92,    -1,    94,    -1,    96,    97,    98,    -1,    -1,    -1,
     102,   103,    12,    13,    14,    15,   108,    -1,   110,   111,
     112,    -1,    -1,    23,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    36,    37,    -1,    39,
      40,    41,    42,    43,    44,    45,    46,    47,    -1,    49,
      -1,    -1,    -1,    -1,    -1,    -1,    56,    57,    -1,    59,
      -1,    61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    79,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,    88,    89,
      90,    91,    92,    -1,    94,    -1,    96,    97,    98,    -1,
      -1,    -1,   102,   103,    -1,    -1,    -1,    -1,   108,    -1,
     110,   111,   112,    12,    13,    -1,    15,    16,    -1,    -1,
      -1,    -1,    -1,    -1,    23,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    36,    37,    -1,
      39,    40,    41,    42,    43,    44,    45,    46,    47,    -1,
      49,    -1,    -1,    -1,    -1,    -1,    -1,    56,    57,    -1,
      59,    -1,    61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,    88,
      89,    90,    91,    92,    -1,    94,    -1,    96,    97,    98,
      -1,    -1,    -1,   102,   103,    12,    13,    -1,    15,   108,
      -1,   110,   111,   112,    -1,    -1,    23,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    36,
      37,    -1,    39,    40,    41,    42,    43,    44,    45,    46,
      47,    -1,    49,    -1,    -1,    -1,    -1,    -1,    -1,    56,
      57,    -1,    59,    -1,    61,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      87,    88,    89,    90,    91,    92,    -1,    94,    -1,    96,
      97,    98,    -1,    -1,    -1,   102,   103,    12,    13,    -1,
      15,   108,    -1,   110,   111,   112,    -1,    -1,    23,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    36,    -1,    -1,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    -1,    49,    -1,    -1,    -1,    -1,    -1,
      -1,    56,    57,    -1,    59,    -1,    61,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    87,    88,    89,    90,    91,    92,    -1,    -1,
      -1,    96,    97,    98,    -1,    -1,    -1,   102,   103,    12,
      13,    -1,    15,   108,    -1,   110,   111,   112,    -1,    -1,
      23,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    39,    40,    41,    42,
      43,    44,    45,    46,    47,    -1,    49,    -1,    -1,    -1,
      -1,    -1,    -1,    56,    57,    -1,    59,    -1,    61,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    79,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    87,    88,    89,    90,    91,    92,
      -1,    -1,    -1,    96,    97,    98,    -1,    -1,    -1,   102,
     103,    12,    13,    -1,    15,   108,    -1,   110,   111,   112,
      -1,    -1,    23,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    -1,    49,    -1,
      -1,    -1,    -1,    -1,    -1,    56,    57,    -1,    59,    -1,
      61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    79,    -1,
      -1,    12,    -1,    -1,    15,    -1,    87,    88,    89,    90,
      91,    92,    23,    -1,    -1,    -1,    97,    98,    -1,    -1,
      -1,   102,   103,    -1,    -1,    36,    37,   108,    -1,   110,
     111,   112,    -1,    -1,    45,    46,    47,    -1,    49,    -1,
      -1,    -1,    -1,    -1,    -1,    56,    57,    -1,    59,    -1,
      61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    79,    -1,
      -1,    12,    -1,    -1,    15,    -1,    87,    88,    89,    90,
      91,    92,    23,    94,    95,    96,    97,    98,    -1,    -1,
      -1,   102,   103,    -1,    -1,    36,    37,   108,    -1,   110,
     111,   112,    -1,    -1,    45,    46,    47,    -1,    49,    -1,
      -1,    -1,    -1,    -1,    -1,    56,    57,    -1,    59,    -1,
      61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    79,    -1,
      -1,    12,    -1,    -1,    15,    -1,    87,    88,    89,    90,
      91,    92,    23,    94,    -1,    96,    97,    98,    -1,    -1,
      -1,   102,   103,    -1,    -1,    36,    -1,   108,    -1,   110,
     111,   112,    -1,    -1,    45,    46,    47,    -1,    49,    -1,
      -1,    -1,    -1,    -1,    -1,    56,    57,    -1,    59,    -1,
      61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    12,    -1,    -1,    15,    -1,    -1,    -1,    79,    -1,
      -1,    -1,    23,    -1,    -1,    -1,    87,    88,    89,    90,
      91,    92,    -1,    -1,    -1,    96,    97,    98,    -1,    -1,
      -1,   102,   103,    -1,    45,    46,    47,   108,    49,   110,
     111,   112,    -1,    -1,    -1,    56,    57,    -1,    59,    -1,
      61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    12,
      -1,    -1,    15,    16,    -1,    -1,    -1,    -1,    79,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    87,    88,    89,    90,
      91,    92,    -1,    -1,    -1,    96,    97,    98,    -1,    -1,
      -1,   102,   103,    46,    47,    -1,    49,   108,    -1,   110,
     111,   112,    -1,    56,    57,    -1,    59,    -1,    61,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    12,    -1,    -1,
      15,    16,    -1,    -1,    -1,    -1,    79,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    87,    88,    89,    90,    91,    92,
      -1,    -1,    -1,    96,    97,    98,    -1,    -1,    -1,   102,
     103,    46,    47,    -1,    49,   108,    -1,   110,   111,   112,
      -1,    56,    57,    -1,    59,    -1,    61,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    12,    -1,    -1,    15,    -1,
      -1,    -1,    -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    87,    88,    89,    90,    91,    92,    -1,    -1,
      -1,    96,    97,    98,    -1,    -1,    -1,   102,   103,    46,
      47,    -1,    49,   108,    -1,   110,   111,   112,    -1,    56,
      57,    -1,    59,    -1,    61,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    70,    -1,    12,    -1,    -1,    15,    -1,
      -1,    -1,    79,    -1,    -1,    -1,    23,    -1,    -1,    -1,
      87,    88,    89,    90,    91,    92,    -1,    -1,    -1,    96,
      97,    98,    -1,    -1,    -1,   102,   103,    -1,    45,    46,
      47,   108,    49,   110,   111,   112,    -1,    -1,    -1,    56,
      57,    -1,    59,    -1,    61,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    12,    -1,    -1,    15,    -1,    -1,    -1,
      -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      87,    88,    89,    90,    91,    92,    -1,    -1,    -1,    -1,
      97,    98,    -1,    -1,    -1,   102,   103,    46,    47,    -1,
      49,   108,    -1,   110,   111,   112,    -1,    56,    57,    -1,
      59,    -1,    61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    12,    -1,    -1,    15,    -1,    -1,    -1,    -1,    -1,
      79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,    88,
      89,    90,    91,    92,    -1,    -1,    -1,    96,    97,    98,
      -1,    -1,    -1,   102,   103,    46,    47,    -1,    49,   108,
      -1,   110,   111,   112,    -1,    56,    57,    -1,    59,    -1,
      61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    12,
      -1,    -1,    15,    -1,    -1,    -1,    -1,    -1,    79,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    87,    88,    89,    90,
      91,    92,    -1,    -1,    -1,    96,    97,    98,    -1,    -1,
      -1,   102,   103,    46,    47,    -1,    49,   108,    -1,   110,
     111,   112,    -1,    56,    57,    -1,    59,    -1,    61,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    12,    -1,    -1,
      15,    -1,    -1,    -1,    -1,    -1,    79,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    87,    88,    89,    90,    91,    92,
      -1,    -1,    -1,    96,    97,    98,    -1,    -1,    -1,   102,
     103,    46,    47,    -1,    49,   108,    -1,   110,   111,   112,
      -1,    56,    57,    -1,    59,    -1,    61,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    87,    88,    89,    90,    91,    92,    -1,    -1,
      -1,    96,    97,    98,    -1,    -1,    -1,   102,   103,    -1,
      -1,    -1,    -1,   108,    -1,   110,   111,   112
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     1,    10,    14,   115,   130,   132,   144,     0,     7,
       8,    11,    12,    15,    46,    47,    49,    55,    56,    57,
      59,    61,    79,    87,    88,    89,    90,    91,    92,    96,
      97,    98,   102,   103,   108,   110,   111,   112,   127,   133,
     134,   136,   139,   146,   147,   157,   158,   159,   161,    10,
      14,   127,   127,   139,   140,   148,    12,    12,   146,   158,
     159,    87,    90,   125,    12,    12,    12,    12,    43,   159,
      12,    12,   158,   158,   146,   158,   159,   159,   158,     1,
      10,    14,    48,    50,    51,    52,    53,    54,    58,    62,
      63,    77,    78,    99,   100,   119,   121,   126,   127,   139,
     143,   150,   152,   156,   162,     9,   127,   130,    13,    23,
      36,    37,    39,    40,    41,    42,    43,    44,    45,    94,
     116,   117,   158,    15,    12,    15,   102,   103,   104,   105,
     109,    70,   110,   111,    18,   156,   156,     9,    16,   118,
      16,   118,    93,    16,   137,   139,   139,    12,   139,   139,
     137,    16,   137,   158,    43,   139,   139,    10,   128,   129,
      14,   128,   151,   151,   161,   139,   151,    12,    12,   151,
     151,   139,   151,    12,    10,   153,   152,   156,    12,   138,
     141,   142,   146,   158,   159,   151,    17,   152,   155,   133,
     156,   134,    96,   139,   147,   139,   139,   139,   139,   139,
     139,   161,   139,    10,   139,    10,   139,   158,   139,   147,
      70,   158,   158,   158,   158,   158,   158,   139,   137,    17,
      17,    10,   139,    45,   139,    15,    16,   118,    87,   160,
     118,   118,    16,    16,   158,   118,   118,    10,   129,    18,
     151,   131,   150,   161,   139,   151,   139,   152,    80,   120,
      17,   145,   140,    23,    45,    94,   116,   117,   158,   118,
      13,    38,    41,    70,   152,   127,    17,   159,    95,   118,
     118,   158,    19,   161,   139,    16,   118,   149,   139,   147,
     139,   147,   139,   161,   137,    14,    45,   149,   149,   154,
      10,   152,    10,    16,    12,   138,   147,   161,   138,   138,
     138,   138,   158,   158,   158,   138,   156,   139,   139,   139,
      87,    10,   135,    16,    16,    16,    16,    16,   118,    16,
     118,    19,    14,   129,   161,   100,    45,   140,    95,    17,
      16,   118,    16,   118,   127,   139,   139,   147,   129,   139,
     149,    12,   161,    16,   138,   159,   159,   156,    16,    16,
      16,   131,    14,   124,   139,    16,    16,    17,   149,   129,
     152,    16,   123,   131,   151,   152,   149,   122,   152
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (thread_stderr, "%s ", Title);					  \
      yy_symbol_print (thread_stderr,						  \
		  Type, Value); \
      YYFPRINTF (thread_stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *bottom, yytype_int16 *top)
#else
static void
yy_stack_print (bottom, top)
    yytype_int16 *bottom;
    yytype_int16 *top;
#endif
{
  YYFPRINTF (thread_stderr, "Stack now");
  for (; bottom <= top; ++bottom)
    YYFPRINTF (thread_stderr, " %d", *bottom);
  YYFPRINTF (thread_stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule)
#else
static void
yy_reduce_print (yyvsp, yyrule)
    YYSTYPE *yyvsp;
    int yyrule;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (thread_stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      fprintf (thread_stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (thread_stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       );
      fprintf (thread_stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yymsg, yytype, yyvaluep)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  YYUSE (yyvaluep);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */



/* The look-ahead symbol.  */
static int yychar;

/* The semantic value of the look-ahead symbol.  */
__thread YYSTYPE yylval;

/* Number of syntax errors so far.  */
static int yynerrs;



/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{
  
  int yystate;
  int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;
#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  yytype_int16 yyssa[YYINITDEPTH];
  yytype_int16 *yyss = yyssa;
  yytype_int16 *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  YYSTYPE *yyvsp;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((thread_stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);

#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;


      YYDPRINTF ((thread_stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((thread_stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     look-ahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to look-ahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((thread_stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((thread_stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 98 "awkgram.y"
    { if (errorflag==0)
			winner = (Node *)stat3(PROGRAM, beginloc, (yyvsp[(1) - (1)].p), endloc); }
    break;

  case 3:
#line 100 "awkgram.y"
    { yyclearin; bracecheck(); SYNTAX("bailing out"); }
    break;

  case 14:
#line 124 "awkgram.y"
    {inloop++;}
    break;

  case 15:
#line 125 "awkgram.y"
    { --inloop; (yyval.p) = stat4(FOR, (yyvsp[(3) - (12)].p), notnull((yyvsp[(6) - (12)].p)), (yyvsp[(9) - (12)].p), (yyvsp[(12) - (12)].p)); }
    break;

  case 16:
#line 126 "awkgram.y"
    {inloop++;}
    break;

  case 17:
#line 127 "awkgram.y"
    { --inloop; (yyval.p) = stat4(FOR, (yyvsp[(3) - (10)].p), NIL, (yyvsp[(7) - (10)].p), (yyvsp[(10) - (10)].p)); }
    break;

  case 18:
#line 128 "awkgram.y"
    {inloop++;}
    break;

  case 19:
#line 129 "awkgram.y"
    { --inloop; (yyval.p) = stat3(IN, (yyvsp[(3) - (8)].p), makearr((yyvsp[(5) - (8)].p)), (yyvsp[(8) - (8)].p)); }
    break;

  case 20:
#line 133 "awkgram.y"
    { setfname((yyvsp[(1) - (1)].cp)); }
    break;

  case 21:
#line 134 "awkgram.y"
    { setfname((yyvsp[(1) - (1)].cp)); }
    break;

  case 22:
#line 138 "awkgram.y"
    { (yyval.p) = notnull((yyvsp[(3) - (4)].p)); }
    break;

  case 27:
#line 150 "awkgram.y"
    { (yyval.i) = 0; }
    break;

  case 29:
#line 155 "awkgram.y"
    { (yyval.i) = 0; }
    break;

  case 31:
#line 161 "awkgram.y"
    { (yyval.p) = 0; }
    break;

  case 33:
#line 166 "awkgram.y"
    { (yyval.p) = 0; }
    break;

  case 34:
#line 167 "awkgram.y"
    { (yyval.p) = (yyvsp[(2) - (3)].p); }
    break;

  case 35:
#line 171 "awkgram.y"
    { (yyval.p) = notnull((yyvsp[(1) - (1)].p)); }
    break;

  case 36:
#line 175 "awkgram.y"
    { (yyval.p) = stat2(PASTAT, (yyvsp[(1) - (1)].p), stat2(PRINT, rectonode(), NIL)); }
    break;

  case 37:
#line 176 "awkgram.y"
    { (yyval.p) = stat2(PASTAT, (yyvsp[(1) - (4)].p), (yyvsp[(3) - (4)].p)); }
    break;

  case 38:
#line 177 "awkgram.y"
    { (yyval.p) = pa2stat((yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p), stat2(PRINT, rectonode(), NIL)); }
    break;

  case 39:
#line 178 "awkgram.y"
    { (yyval.p) = pa2stat((yyvsp[(1) - (6)].p), (yyvsp[(3) - (6)].p), (yyvsp[(5) - (6)].p)); }
    break;

  case 40:
#line 179 "awkgram.y"
    { (yyval.p) = stat2(PASTAT, NIL, (yyvsp[(2) - (3)].p)); }
    break;

  case 41:
#line 181 "awkgram.y"
    { beginloc = linkum(beginloc, (yyvsp[(3) - (4)].p)); (yyval.p) = 0; }
    break;

  case 42:
#line 183 "awkgram.y"
    { endloc = linkum(endloc, (yyvsp[(3) - (4)].p)); (yyval.p) = 0; }
    break;

  case 43:
#line 184 "awkgram.y"
    {infunc++;}
    break;

  case 44:
#line 185 "awkgram.y"
    { infunc--; curfname=0; defn((Cell *)(yyvsp[(2) - (9)].p), (yyvsp[(4) - (9)].p), (yyvsp[(8) - (9)].p)); (yyval.p) = 0; }
    break;

  case 46:
#line 190 "awkgram.y"
    { (yyval.p) = linkum((yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 48:
#line 195 "awkgram.y"
    { (yyval.p) = linkum((yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 49:
#line 199 "awkgram.y"
    { (yyval.p) = op2((yyvsp[(2) - (3)].i), (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 50:
#line 201 "awkgram.y"
    { (yyval.p) = op3(CONDEXPR, notnull((yyvsp[(1) - (5)].p)), (yyvsp[(3) - (5)].p), (yyvsp[(5) - (5)].p)); }
    break;

  case 51:
#line 203 "awkgram.y"
    { (yyval.p) = op2(BOR, notnull((yyvsp[(1) - (3)].p)), notnull((yyvsp[(3) - (3)].p))); }
    break;

  case 52:
#line 205 "awkgram.y"
    { (yyval.p) = op2(AND, notnull((yyvsp[(1) - (3)].p)), notnull((yyvsp[(3) - (3)].p))); }
    break;

  case 53:
#line 206 "awkgram.y"
    { (yyval.p) = op3((yyvsp[(2) - (3)].i), NIL, (yyvsp[(1) - (3)].p), (Node*)makedfa((yyvsp[(3) - (3)].s), 0)); }
    break;

  case 54:
#line 208 "awkgram.y"
    { if (constnode((yyvsp[(3) - (3)].p)))
			(yyval.p) = op3((yyvsp[(2) - (3)].i), NIL, (yyvsp[(1) - (3)].p), (Node*)makedfa(strnode((yyvsp[(3) - (3)].p)), 0));
		  else
			(yyval.p) = op3((yyvsp[(2) - (3)].i), (Node *)1, (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 55:
#line 212 "awkgram.y"
    { (yyval.p) = op2(INTEST, (yyvsp[(1) - (3)].p), makearr((yyvsp[(3) - (3)].p))); }
    break;

  case 56:
#line 213 "awkgram.y"
    { (yyval.p) = op2(INTEST, (yyvsp[(2) - (5)].p), makearr((yyvsp[(5) - (5)].p))); }
    break;

  case 57:
#line 214 "awkgram.y"
    { (yyval.p) = op2(CAT, (yyvsp[(1) - (2)].p), (yyvsp[(2) - (2)].p)); }
    break;

  case 60:
#line 220 "awkgram.y"
    { (yyval.p) = op2((yyvsp[(2) - (3)].i), (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 61:
#line 222 "awkgram.y"
    { (yyval.p) = op3(CONDEXPR, notnull((yyvsp[(1) - (5)].p)), (yyvsp[(3) - (5)].p), (yyvsp[(5) - (5)].p)); }
    break;

  case 62:
#line 224 "awkgram.y"
    { (yyval.p) = op2(BOR, notnull((yyvsp[(1) - (3)].p)), notnull((yyvsp[(3) - (3)].p))); }
    break;

  case 63:
#line 226 "awkgram.y"
    { (yyval.p) = op2(AND, notnull((yyvsp[(1) - (3)].p)), notnull((yyvsp[(3) - (3)].p))); }
    break;

  case 64:
#line 227 "awkgram.y"
    { (yyval.p) = op2((yyvsp[(2) - (3)].i), (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 65:
#line 228 "awkgram.y"
    { (yyval.p) = op2((yyvsp[(2) - (3)].i), (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 66:
#line 229 "awkgram.y"
    { (yyval.p) = op2((yyvsp[(2) - (3)].i), (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 67:
#line 230 "awkgram.y"
    { (yyval.p) = op2((yyvsp[(2) - (3)].i), (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 68:
#line 231 "awkgram.y"
    { (yyval.p) = op2((yyvsp[(2) - (3)].i), (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 69:
#line 232 "awkgram.y"
    { (yyval.p) = op2((yyvsp[(2) - (3)].i), (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 70:
#line 233 "awkgram.y"
    { (yyval.p) = op3((yyvsp[(2) - (3)].i), NIL, (yyvsp[(1) - (3)].p), (Node*)makedfa((yyvsp[(3) - (3)].s), 0)); }
    break;

  case 71:
#line 235 "awkgram.y"
    { if (constnode((yyvsp[(3) - (3)].p)))
			(yyval.p) = op3((yyvsp[(2) - (3)].i), NIL, (yyvsp[(1) - (3)].p), (Node*)makedfa(strnode((yyvsp[(3) - (3)].p)), 0));
		  else
			(yyval.p) = op3((yyvsp[(2) - (3)].i), (Node *)1, (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 72:
#line 239 "awkgram.y"
    { (yyval.p) = op2(INTEST, (yyvsp[(1) - (3)].p), makearr((yyvsp[(3) - (3)].p))); }
    break;

  case 73:
#line 240 "awkgram.y"
    { (yyval.p) = op2(INTEST, (yyvsp[(2) - (5)].p), makearr((yyvsp[(5) - (5)].p))); }
    break;

  case 74:
#line 241 "awkgram.y"
    { 
			if (safe) SYNTAX("cmd | getline is unsafe");
			else (yyval.p) = op3(GETLINE, (yyvsp[(4) - (4)].p), itonp((yyvsp[(2) - (4)].i)), (yyvsp[(1) - (4)].p)); }
    break;

  case 75:
#line 244 "awkgram.y"
    { 
			if (safe) SYNTAX("cmd | getline is unsafe");
			else (yyval.p) = op3(GETLINE, (Node*)0, itonp((yyvsp[(2) - (3)].i)), (yyvsp[(1) - (3)].p)); }
    break;

  case 76:
#line 247 "awkgram.y"
    { (yyval.p) = op2(CAT, (yyvsp[(1) - (2)].p), (yyvsp[(2) - (2)].p)); }
    break;

  case 79:
#line 253 "awkgram.y"
    { (yyval.p) = linkum((yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 80:
#line 254 "awkgram.y"
    { (yyval.p) = linkum((yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 82:
#line 259 "awkgram.y"
    { (yyval.p) = linkum((yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 83:
#line 263 "awkgram.y"
    { (yyval.p) = rectonode(); }
    break;

  case 85:
#line 265 "awkgram.y"
    { (yyval.p) = (yyvsp[(2) - (3)].p); }
    break;

  case 94:
#line 282 "awkgram.y"
    { (yyval.p) = op3(MATCH, NIL, rectonode(), (Node*)makedfa((yyvsp[(1) - (1)].s), 0)); }
    break;

  case 95:
#line 283 "awkgram.y"
    { (yyval.p) = op1(NOT, notnull((yyvsp[(2) - (2)].p))); }
    break;

  case 96:
#line 287 "awkgram.y"
    {startreg();}
    break;

  case 97:
#line 287 "awkgram.y"
    { (yyval.s) = (yyvsp[(3) - (4)].s); }
    break;

  case 100:
#line 295 "awkgram.y"
    { 
			if (safe) SYNTAX("print | is unsafe");
			else (yyval.p) = stat3((yyvsp[(1) - (4)].i), (yyvsp[(2) - (4)].p), itonp((yyvsp[(3) - (4)].i)), (yyvsp[(4) - (4)].p)); }
    break;

  case 101:
#line 298 "awkgram.y"
    {
			if (safe) SYNTAX("print >> is unsafe");
			else (yyval.p) = stat3((yyvsp[(1) - (4)].i), (yyvsp[(2) - (4)].p), itonp((yyvsp[(3) - (4)].i)), (yyvsp[(4) - (4)].p)); }
    break;

  case 102:
#line 301 "awkgram.y"
    {
			if (safe) SYNTAX("print > is unsafe");
			else (yyval.p) = stat3((yyvsp[(1) - (4)].i), (yyvsp[(2) - (4)].p), itonp((yyvsp[(3) - (4)].i)), (yyvsp[(4) - (4)].p)); }
    break;

  case 103:
#line 304 "awkgram.y"
    { (yyval.p) = stat3((yyvsp[(1) - (2)].i), (yyvsp[(2) - (2)].p), NIL, NIL); }
    break;

  case 104:
#line 305 "awkgram.y"
    { (yyval.p) = stat2(DELETE, makearr((yyvsp[(2) - (5)].p)), (yyvsp[(4) - (5)].p)); }
    break;

  case 105:
#line 306 "awkgram.y"
    { (yyval.p) = stat2(DELETE, makearr((yyvsp[(2) - (2)].p)), 0); }
    break;

  case 106:
#line 307 "awkgram.y"
    { (yyval.p) = exptostat((yyvsp[(1) - (1)].p)); }
    break;

  case 107:
#line 308 "awkgram.y"
    { yyclearin; SYNTAX("illegal statement"); }
    break;

  case 110:
#line 317 "awkgram.y"
    { if (!inloop) SYNTAX("break illegal outside of loops");
				  (yyval.p) = stat1(BREAK, NIL); }
    break;

  case 111:
#line 319 "awkgram.y"
    {  if (!inloop) SYNTAX("continue illegal outside of loops");
				  (yyval.p) = stat1(CONTINUE, NIL); }
    break;

  case 112:
#line 321 "awkgram.y"
    {inloop++;}
    break;

  case 113:
#line 321 "awkgram.y"
    {--inloop;}
    break;

  case 114:
#line 322 "awkgram.y"
    { (yyval.p) = stat2(DO, (yyvsp[(3) - (9)].p), notnull((yyvsp[(7) - (9)].p))); }
    break;

  case 115:
#line 323 "awkgram.y"
    { (yyval.p) = stat1(EXIT, (yyvsp[(2) - (3)].p)); }
    break;

  case 116:
#line 324 "awkgram.y"
    { (yyval.p) = stat1(EXIT, NIL); }
    break;

  case 118:
#line 326 "awkgram.y"
    { (yyval.p) = stat3(IF, (yyvsp[(1) - (4)].p), (yyvsp[(2) - (4)].p), (yyvsp[(4) - (4)].p)); }
    break;

  case 119:
#line 327 "awkgram.y"
    { (yyval.p) = stat3(IF, (yyvsp[(1) - (2)].p), (yyvsp[(2) - (2)].p), NIL); }
    break;

  case 120:
#line 328 "awkgram.y"
    { (yyval.p) = (yyvsp[(2) - (3)].p); }
    break;

  case 121:
#line 329 "awkgram.y"
    { if (infunc)
				SYNTAX("next is illegal inside a function");
			  (yyval.p) = stat1(NEXT, NIL); }
    break;

  case 122:
#line 332 "awkgram.y"
    { if (infunc)
				SYNTAX("nextfile is illegal inside a function");
			  (yyval.p) = stat1(NEXTFILE, NIL); }
    break;

  case 123:
#line 335 "awkgram.y"
    { (yyval.p) = stat1(RETURN, (yyvsp[(2) - (3)].p)); }
    break;

  case 124:
#line 336 "awkgram.y"
    { (yyval.p) = stat1(RETURN, NIL); }
    break;

  case 126:
#line 338 "awkgram.y"
    {inloop++;}
    break;

  case 127:
#line 338 "awkgram.y"
    { --inloop; (yyval.p) = stat2(WHILE, (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 128:
#line 339 "awkgram.y"
    { (yyval.p) = 0; }
    break;

  case 130:
#line 344 "awkgram.y"
    { (yyval.p) = linkum((yyvsp[(1) - (2)].p), (yyvsp[(2) - (2)].p)); }
    break;

  case 133:
#line 352 "awkgram.y"
    { (yyval.p) = op2(DIVEQ, (yyvsp[(1) - (4)].p), (yyvsp[(4) - (4)].p)); }
    break;

  case 134:
#line 353 "awkgram.y"
    { (yyval.p) = op2(ADD, (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 135:
#line 354 "awkgram.y"
    { (yyval.p) = op2(MINUS, (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 136:
#line 355 "awkgram.y"
    { (yyval.p) = op2(MULT, (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 137:
#line 356 "awkgram.y"
    { (yyval.p) = op2(DIVIDE, (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 138:
#line 357 "awkgram.y"
    { (yyval.p) = op2(DIVIDE, (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 139:
#line 358 "awkgram.y"
    { (yyval.p) = op2(MOD, (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 140:
#line 359 "awkgram.y"
    { (yyval.p) = op2(POWER, (yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].p)); }
    break;

  case 141:
#line 360 "awkgram.y"
    { (yyval.p) = op1(UMINUS, (yyvsp[(2) - (2)].p)); }
    break;

  case 142:
#line 361 "awkgram.y"
    { (yyval.p) = op1(UPLUS, (yyvsp[(2) - (2)].p)); }
    break;

  case 143:
#line 362 "awkgram.y"
    { (yyval.p) = op1(NOT, notnull((yyvsp[(2) - (2)].p))); }
    break;

  case 144:
#line 363 "awkgram.y"
    { (yyval.p) = op2(BLTIN, itonp((yyvsp[(1) - (3)].i)), rectonode()); }
    break;

  case 145:
#line 364 "awkgram.y"
    { (yyval.p) = op2(BLTIN, itonp((yyvsp[(1) - (4)].i)), (yyvsp[(3) - (4)].p)); }
    break;

  case 146:
#line 365 "awkgram.y"
    { (yyval.p) = op2(BLTIN, itonp((yyvsp[(1) - (1)].i)), rectonode()); }
    break;

  case 147:
#line 366 "awkgram.y"
    { (yyval.p) = op2(CALL, celltonode((yyvsp[(1) - (3)].cp),CVAR), NIL); }
    break;

  case 148:
#line 367 "awkgram.y"
    { (yyval.p) = op2(CALL, celltonode((yyvsp[(1) - (4)].cp),CVAR), (yyvsp[(3) - (4)].p)); }
    break;

  case 149:
#line 368 "awkgram.y"
    { (yyval.p) = op1(CLOSE, (yyvsp[(2) - (2)].p)); }
    break;

  case 150:
#line 369 "awkgram.y"
    { (yyval.p) = op1(PREDECR, (yyvsp[(2) - (2)].p)); }
    break;

  case 151:
#line 370 "awkgram.y"
    { (yyval.p) = op1(PREINCR, (yyvsp[(2) - (2)].p)); }
    break;

  case 152:
#line 371 "awkgram.y"
    { (yyval.p) = op1(POSTDECR, (yyvsp[(1) - (2)].p)); }
    break;

  case 153:
#line 372 "awkgram.y"
    { (yyval.p) = op1(POSTINCR, (yyvsp[(1) - (2)].p)); }
    break;

  case 154:
#line 373 "awkgram.y"
    { (yyval.p) = op3(GETLINE, (yyvsp[(2) - (4)].p), itonp((yyvsp[(3) - (4)].i)), (yyvsp[(4) - (4)].p)); }
    break;

  case 155:
#line 374 "awkgram.y"
    { (yyval.p) = op3(GETLINE, NIL, itonp((yyvsp[(2) - (3)].i)), (yyvsp[(3) - (3)].p)); }
    break;

  case 156:
#line 375 "awkgram.y"
    { (yyval.p) = op3(GETLINE, (yyvsp[(2) - (2)].p), NIL, NIL); }
    break;

  case 157:
#line 376 "awkgram.y"
    { (yyval.p) = op3(GETLINE, NIL, NIL, NIL); }
    break;

  case 158:
#line 378 "awkgram.y"
    { (yyval.p) = op2(INDEX, (yyvsp[(3) - (6)].p), (yyvsp[(5) - (6)].p)); }
    break;

  case 159:
#line 380 "awkgram.y"
    { SYNTAX("index() doesn't permit regular expressions");
		  (yyval.p) = op2(INDEX, (yyvsp[(3) - (6)].p), (Node*)(yyvsp[(5) - (6)].s)); }
    break;

  case 160:
#line 382 "awkgram.y"
    { (yyval.p) = (yyvsp[(2) - (3)].p); }
    break;

  case 161:
#line 384 "awkgram.y"
    { (yyval.p) = op3(MATCHFCN, NIL, (yyvsp[(3) - (6)].p), (Node*)makedfa((yyvsp[(5) - (6)].s), 1)); }
    break;

  case 162:
#line 386 "awkgram.y"
    { if (constnode((yyvsp[(5) - (6)].p)))
			(yyval.p) = op3(MATCHFCN, NIL, (yyvsp[(3) - (6)].p), (Node*)makedfa(strnode((yyvsp[(5) - (6)].p)), 1));
		  else
			(yyval.p) = op3(MATCHFCN, (Node *)1, (yyvsp[(3) - (6)].p), (yyvsp[(5) - (6)].p)); }
    break;

  case 163:
#line 390 "awkgram.y"
    { (yyval.p) = celltonode((yyvsp[(1) - (1)].cp), CCON); }
    break;

  case 164:
#line 392 "awkgram.y"
    { (yyval.p) = op4(SPLIT, (yyvsp[(3) - (8)].p), makearr((yyvsp[(5) - (8)].p)), (yyvsp[(7) - (8)].p), (Node*)STRING); }
    break;

  case 165:
#line 394 "awkgram.y"
    { (yyval.p) = op4(SPLIT, (yyvsp[(3) - (8)].p), makearr((yyvsp[(5) - (8)].p)), (Node*)makedfa((yyvsp[(7) - (8)].s), 1), (Node *)REGEXPR); }
    break;

  case 166:
#line 396 "awkgram.y"
    { (yyval.p) = op4(SPLIT, (yyvsp[(3) - (6)].p), makearr((yyvsp[(5) - (6)].p)), NIL, (Node*)STRING); }
    break;

  case 167:
#line 397 "awkgram.y"
    { (yyval.p) = op1((yyvsp[(1) - (4)].i), (yyvsp[(3) - (4)].p)); }
    break;

  case 168:
#line 398 "awkgram.y"
    { (yyval.p) = celltonode((yyvsp[(1) - (1)].cp), CCON); }
    break;

  case 169:
#line 400 "awkgram.y"
    { (yyval.p) = op4((yyvsp[(1) - (6)].i), NIL, (Node*)makedfa((yyvsp[(3) - (6)].s), 1), (yyvsp[(5) - (6)].p), rectonode()); }
    break;

  case 170:
#line 402 "awkgram.y"
    { if (constnode((yyvsp[(3) - (6)].p)))
			(yyval.p) = op4((yyvsp[(1) - (6)].i), NIL, (Node*)makedfa(strnode((yyvsp[(3) - (6)].p)), 1), (yyvsp[(5) - (6)].p), rectonode());
		  else
			(yyval.p) = op4((yyvsp[(1) - (6)].i), (Node *)1, (yyvsp[(3) - (6)].p), (yyvsp[(5) - (6)].p), rectonode()); }
    break;

  case 171:
#line 407 "awkgram.y"
    { (yyval.p) = op4((yyvsp[(1) - (8)].i), NIL, (Node*)makedfa((yyvsp[(3) - (8)].s), 1), (yyvsp[(5) - (8)].p), (yyvsp[(7) - (8)].p)); }
    break;

  case 172:
#line 409 "awkgram.y"
    { if (constnode((yyvsp[(3) - (8)].p)))
			(yyval.p) = op4((yyvsp[(1) - (8)].i), NIL, (Node*)makedfa(strnode((yyvsp[(3) - (8)].p)), 1), (yyvsp[(5) - (8)].p), (yyvsp[(7) - (8)].p));
		  else
			(yyval.p) = op4((yyvsp[(1) - (8)].i), (Node *)1, (yyvsp[(3) - (8)].p), (yyvsp[(5) - (8)].p), (yyvsp[(7) - (8)].p)); }
    break;

  case 173:
#line 414 "awkgram.y"
    { (yyval.p) = op3(SUBSTR, (yyvsp[(3) - (8)].p), (yyvsp[(5) - (8)].p), (yyvsp[(7) - (8)].p)); }
    break;

  case 174:
#line 416 "awkgram.y"
    { (yyval.p) = op3(SUBSTR, (yyvsp[(3) - (6)].p), (yyvsp[(5) - (6)].p), NIL); }
    break;

  case 177:
#line 422 "awkgram.y"
    { (yyval.p) = op2(ARRAY, makearr((yyvsp[(1) - (4)].p)), (yyvsp[(3) - (4)].p)); }
    break;

  case 178:
#line 423 "awkgram.y"
    { (yyval.p) = op1(INDIRECT, celltonode((yyvsp[(1) - (1)].cp), CVAR)); }
    break;

  case 179:
#line 424 "awkgram.y"
    { (yyval.p) = op1(INDIRECT, (yyvsp[(2) - (2)].p)); }
    break;

  case 180:
#line 428 "awkgram.y"
    { arglist = (yyval.p) = 0; }
    break;

  case 181:
#line 429 "awkgram.y"
    { arglist = (yyval.p) = celltonode((yyvsp[(1) - (1)].cp),CVAR); }
    break;

  case 182:
#line 430 "awkgram.y"
    {
			checkdup((yyvsp[(1) - (3)].p), (yyvsp[(3) - (3)].cp));
			arglist = (yyval.p) = linkum((yyvsp[(1) - (3)].p),celltonode((yyvsp[(3) - (3)].cp),CVAR)); }
    break;

  case 183:
#line 436 "awkgram.y"
    { (yyval.p) = celltonode((yyvsp[(1) - (1)].cp), CVAR); }
    break;

  case 184:
#line 437 "awkgram.y"
    { (yyval.p) = op1(ARG, itonp((yyvsp[(1) - (1)].i))); }
    break;

  case 185:
#line 438 "awkgram.y"
    { (yyval.p) = op1(VARNF, (Node *) (yyvsp[(1) - (1)].cp)); }
    break;

  case 186:
#line 443 "awkgram.y"
    { (yyval.p) = notnull((yyvsp[(3) - (4)].p)); }
    break;


/* Line 1267 of yacc.c.  */
#line 3496 "y.tab.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;


  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (yymsg);
	  }
	else
	  {
	    yyerror (YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}


#line 446 "awkgram.y"


void setfname(Cell *p)
{
	if (isarr(p))
		SYNTAX("%s is an array, not a function", p->nval);
	else if (isfcn(p))
		SYNTAX("you can't define function %s more than once", p->nval);
	curfname = p->nval;
}

int constnode(Node *p)
{
	return isvalue(p) && ((Cell *) (p->narg[0]))->csub == CCON;
}

char *strnode(Node *p)
{
	return ((Cell *)(p->narg[0]))->sval;
}

Node *notnull(Node *n)
{
	switch (n->nobj) {
	case LE: case LT: case EQ: case NE: case GT: case GE:
	case BOR: case AND: case NOT:
		return n;
	default:
		return op2(NE, n, nullnode);
	}
}

void checkdup(Node *vl, Cell *cp)	/* check if name already in list */
{
	char *s = cp->nval;
	for ( ; vl; vl = vl->nnext) {
		if (strcmp(s, ((Cell *)(vl->narg[0]))->nval) == 0) {
			SYNTAX("duplicate argument %s", s);
			break;
		}
	}
}

