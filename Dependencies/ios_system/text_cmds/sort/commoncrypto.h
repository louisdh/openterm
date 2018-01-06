#include <CommonCrypto/CommonDigest.h>

#define MD5_CTX CC_MD5_CTX
#define MD5Init CC_MD5_Init
#define MD5Update CC_MD5_Update

char *MD5End(CC_MD5_CTX *, char *);
char *MD5File(const char *, char *);
