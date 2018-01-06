/* mdXhl.c
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <phk@FreeBSD.org> wrote this file.  As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return.   Poul-Henning Kamp
 * ----------------------------------------------------------------------------
 */

#include <sys/cdefs.h>
__FBSDID("$FreeBSD: head/lib/libmd/mdXhl.c 294037 2016-01-14 21:08:23Z jtl $");

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

#include "commoncrypto.h"

#define LENGTH CC_MD5_DIGEST_LENGTH

char *MD5FileChunk(const char *, char *, off_t, off_t);

char *
MD5End(CC_MD5_CTX *ctx, char *buf)
{
	int i;
	unsigned char digest[LENGTH];
	static const char hex[]="0123456789abcdef";

	if (!buf)
		buf = malloc(2*LENGTH + 1);
	if (!buf)
		return 0;
	CC_MD5_Final(digest, ctx);
	for (i = 0; i < LENGTH; i++) {
		buf[i+i] = hex[digest[i] >> 4];
		buf[i+i+1] = hex[digest[i] & 0x0f];
	}
	buf[i+i] = '\0';
	return buf;
}

char *
MD5File(const char *filename, char *buf)
{
	return (MD5FileChunk(filename, buf, 0, 0));
}

char *
MD5FileChunk(const char *filename, char *buf, off_t ofs, off_t len)
{
	unsigned char buffer[16*1024];
	CC_MD5_CTX ctx;
	int fd, readrv, e;
	off_t remain;

	if (len < 0) {
		errno = EINVAL;
		return NULL;
	}

	CC_MD5_Init(&ctx);
	fd = open(filename, O_RDONLY);
	if (fd < 0)
		return NULL;
	if (ofs != 0) {
		errno = 0;
		if (lseek(fd, ofs, SEEK_SET) != ofs ||
		    (ofs == -1 && errno != 0)) {
			readrv = -1;
			goto error;
		}
	}
	remain = len;
	readrv = 0;
	while (len == 0 || remain > 0) {
		if (len == 0 || remain > (off_t)sizeof(buffer))
			readrv = read(fd, buffer, sizeof(buffer));
		else
			readrv = read(fd, buffer, remain);
		if (readrv <= 0) 
			break;
		CC_MD5_Update(&ctx, buffer, readrv);
		remain -= readrv;
	} 
error:
	e = errno;
	close(fd);
	errno = e;
	if (readrv < 0)
		return NULL;
	return (MD5End(&ctx, buf));
}
