# ios_system: Drop-in replacement for system() in iOS programs

When porting Unix utilities to iOS (vim, TeX, python...), sometimes the source code executes system commands, using `system()` calls. These calls are rejected at compile time, with: 
`error: 'system' is unavailable: not available on iOS`. 

This project provides a drop-in replacement for `system()`. Simply add the following lines at the beginning of you header file: 
```cpp
extern int ios_system(char* cmd);
#define system ios_system
```
link with the `ios_system.framework`, and your calls to `system()` will be handled by this framework.

The commands available are defined in `ios_system.m`. They are configurable through a series of `#define`. 

There are, first, shell commands (`ls`, `cp`, `rm`...), archive commands (`curl`, `scp`, `sftp`, `tar`, `gzip`, `compress`...) plus a few interpreted languages (`python`, `lua`, `TeX`). Scripts written in one of the interpreted languages are also executed, if they are in the `$PATH`. 

For each set of commands, we need to provide the associated framework. Frameworks for small commands are in this project. Frameworks for interpreted languages are larger, and available separately: [python](https://github.com/holzschu/python_ios), [lua](https://github.com/holzschu/lua_ios) and [TeX](https://github.com/holzschu/lib-tex). Some commands (`curl`, `python`) require `OpenSSH` and `libssl2`, which you will have to download and compile separately.

This `ios_system` framework has been successfully ported into two shells, [Blink](https://github.com/holzschu/blink) and [Terminal](https://github.com/louisdh/terminal) and into an editor, [iVim](https://github.com/holzschu/iVim). Each time, it provides a Unix look-and-feel (well, mostly feel). 

**Issues:** In iOS, you cannot write in the `~` directory, only in `~/Documents/`, `~/Library/` and `~/tmp`. Most Unix programs assume the configuration files are in `$HOME`. 
So either you redefine `$HOME` to `~/Documents/` or you set configuration variables (using `setenv`) to some other place. This is done in the `initializeEnvironment()` function. 

Here's what I have:
```powershell
setenv PATH = $PATH:~/Library/bin:~/Documents/bin
setenv PYTHONHOME = $HOME/Library/
setenv SSH_HOME = $HOME/Documents/
setenv CURL_HOME = $HOME/Documents/
setenv HGRCPATH = $HOME/Documents/.hgrc/
setenv SSL_CERT_FILE = $HOME/Documents/cacert.pem
```
Your Mileage May Vary. Note that iOS already defines `$HOME` and `$PATH`. 

## scp and sftp:

`scp`and `sftp` are implemented by rewriting them as `curl` commands. For example, `scp user@host:~/distantfile localfile` becomes (internally) `curl scp://user@host/~/distantFile -o localFile`. This was done to keep the size of the framework as small as possible. It will work for most of the users and most of the commands. However, it has consequences:
- `scp` from distant file to distant file probably won't work, only from local to distant or distant to local. 
- The flags are those from `curl`, not `scp`. Except `-q` (quiet) which I remapped to `-s` (silent). 
- The config file is `.curlrc`, not `.ssh/config`. 
- The library used internally is `libssh2`, not `OpenSSH`.


## Installation:

- Run the script `./get_sources.sh`. This will download the latest sources form [Apple OpenSource](https://opensource.apple.com) and patch them for compatibility with iOS. 
- (optional) Run the script `./get_python_lua.sh`.  It will download the sources for  [python](https://github.com/holzschu/python_ios) and [lua](https://github.com/holzschu/lua_ios). 
- If you do *not* need Python, delete the `python_grp` folder, comment out the `#define FEAT_PYTHON` line in `ios_system.m` (if you are linking with iVim, also remove it from the `CFLAGS` of iVim).
- If you *do* need Python: open `../python_ios/libffi-3.2.1/libffi.xcodeproj/`, hit Build. It will create `libffi.a`. Click on Products, control-click on `libffi.a`, go to "Show in Finder". Copy it to the `../python_ios/` directory. 
- Same with Lua: if you do not need it, comment the  `#define FEAT_LUA` line in `ios_system.m`.
- If you need Tex, follow the instructions at https://github.com/holzschu/lib-tex, and link with the dynamic libraries created. Otherwise, comment out `#define TEX_COMMANDS`.
- Open the Xcode project `ios_system.xcodeproj` and hit build. This will create the `ios_system` framework, ready to be included in your own projects. Alternatively, drag `ios_system.xcodeproj` into you project, add `ios_system.framework` to your linked binaries and compile. 

## Integration with your app:

The simplest way to integrate `ios_system` into your app is to just replace all calls to `system()` with calls to `ios_system()`. If you need more control and information, the following functions are available: 

- `NSArray* commandsAsArray()` returns an array with all the commands available, if you need them for helping users. 
- `NSString* commandsAsString()` same, but with a `NSString*`. 
- `initializeEnvironment()` sets environment variables to sensible defaults. 
- `ios_executable(char* inputCmd)` returns true if `inputCmd` is one of the commands defined inside `ios_system`. 
- `int ios_setMiniRoot(NSString* mRoot)` lets you set the sandbox directory, so users are not exposed to files outside the sandbox. The argument is the path to a directory. It will not be possible to `cd` to directories above this one. Returns 1 if succesful, 0 if not. 
- `replaceCommand(NSString* commandName, int (*newFunction)(int argc, char *argv[]), bool allOccurences)` lets you replace an existing command implementation with your own. 

Sample use: `replaceCommand(@"ls", gnu_ls_main, true);`: Replaces all calls to `ls` to calls to `gnu_ls_main`. The last argument tells whether you want to replace only the function associated with `ls` (if `false`) or all the commands that used the function previously associated with `ls`(if true). For example, `compress` and `uncompress` are both done with the same function, `compress_main` (and the actual behaviour depends on `argv[0]`). Only you can know whether your replacement function handles both roles, or only one of them. 

### Licensing:

As much as possible, I used the BSD version of the tools. More precisely:
- awk: <a href="https://github.com/onetrueawk/awk/blob/master/LICENSE">OpenSource license</a>.
- curl, scp, sftp: <a href="https://curl.haxx.se/docs/copyright.html">MIT/X derivate license</a>.
- lua: <a href="https://www.lua.org/license.html">MIT License</a>.
- python: <a href="https://docs.python.org/2.7/license.html">Python license</a>.
- libssh2: <a href='https://en.wikipedia.org/wiki/BSD_licenses#3-clause_license_("BSD_License_2.0",_"Revised_BSD_License",_"New_BSD_License",_or_"Modified_BSD_License")'>Revised BSD License</a> (a.k.a. 3-clause BSD license).
- egrep, fgrep, grep, gzip, gunzip: <a href='https://en.wikipedia.org/wiki/BSD_licenses#2-clause_license_("Simplified_BSD_License"_or_"FreeBSD_License")'>Simplified BSD License</a> (2-clause BSD license).
- cat, chflag, compress, cp, date, echo, env, link, ln, printenv, pwd, sed, tar, uncompress, uptime, <a href='https://en.wikipedia.org/wiki/BSD_licenses#3-clause_license_("BSD_License_2.0",_"Revised_BSD_License",_"New_BSD_License",_or_"Modified_BSD_License")'>Revised BSD License</a> (a.k.a. 3-clause BSD license).
- chgrp, chksum, chmod, chown, df, du, groups, id, ls, mkdir, mv, readlink, rm, rmdir, stat, sum, touch, tr, uname, wc, whoami: <a href='https://en.wikipedia.org/wiki/BSD_licenses#4-clause_license_(original_"BSD_License")'>Original BSD License</a> (4-clause BSD license)
- pdftex, luatex and all TeX-based programs: <a href="https://www.gnu.org/licenses/gpl.html">GNU General Public License</a>.

Using BSD versions has consequences on the flags and how they work. For example, there are two versions of `sed`, the BSD version and the GNU version. They have roughly the same behaviour, but differ on `-i` (in place): the GNU version overwrites the file if you don't provide an extension, the BSD version won't work unless you provide the extension to use on the backup file (and will backup the input file with that extension). 
