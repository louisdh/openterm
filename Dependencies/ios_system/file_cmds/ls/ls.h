/*
 * Copyright (c) 1989, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Michael Fischbein.
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
 *
 *	from: @(#)ls.h	8.1 (Berkeley) 5/31/93
 * $FreeBSD: src/bin/ls/ls.h,v 1.18 2002/05/19 02:51:36 tjr Exp $
 */

#define NO_PRINT	1

extern __thread long blocksize;		/* block size units */

extern __thread int f_accesstime;	/* use time of last access */
extern __thread int f_birthtime;		/* use time of file birth */
extern __thread int f_flags;		/* show flags associated with a file */
extern __thread int f_humanval;		/* show human-readable file sizes */
extern __thread int f_inode;		/* print inode */
extern __thread int f_longform;		/* long listing format */
extern __thread int f_octal;		/* print unprintables in octal */
extern __thread int f_octal_escape;	/* like f_octal but use C escapes if possible */
extern __thread int f_nonprint;		/* show unprintables as ? */
extern __thread int f_sectime;		/* print the real time for all files */
extern __thread int f_size;		/* list size in short listing */
extern __thread int f_slash;		/* append a '/' if the file is a directory */
extern __thread int f_sortacross;	/* sort across rows, not down columns */
extern __thread int f_statustime;	/* use time of last mode change */
extern __thread int f_notabs;		/* don't use tab-separated multi-col output */
extern __thread int f_type;		/* add type character for non-regular files */
extern __thread int f_acl;		/* print ACLs in long format */
extern __thread int f_xattr;		/* print extended attributes in long format  */
extern __thread int f_group;		/* list group without owner */
extern __thread int f_owner;		/* list owner without group */
#ifdef COLORLS
extern __thread int f_color;		/* add type in color for non-regular files */
#endif
extern __thread int f_numericonly;	/* don't convert uid/gid to name */

#ifdef __APPLE__
#include <sys/acl.h>
#endif // __APPLE__

typedef struct {
	FTSENT *list;
	u_int64_t btotal;
	int bcfile;
	int entries;
	int maxlen;
	u_int s_block;
	u_int s_flags;
	u_int s_lattr;
	u_int s_group;
	u_int s_inode;
	u_int s_nlink;
	u_int s_size;
	u_int s_user;
} DISPLAY;

typedef struct {
	char *user;
	char *group;
	char *flags;
#ifndef __APPLE__
	char *lattr;
#else
	char	*xattr_names;	/* f_xattr */
	int	*xattr_sizes;
	acl_t	acl;		/* f_acl */
        int	xattr_count;
	char	mode_suffix;	/* @ | + | <space> */
#endif /* __APPLE__ */
	char data[1];
} NAMES;
