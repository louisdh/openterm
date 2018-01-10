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

There are, first, shell commands (`ls`, `cp`, `rm`...), archive commands (`curl`, `tar`, `gz`, `compress`...) plus a few interpreted languages (`python`, `lua`, `TeX`). Scripts written in one of the interpreted languages are also executed, if they are in the `$PATH`. 

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

## Installation:

- Run the script `./get_sources.sh`. This will download the latest sources form [Apple OpenSource](https://opensource.apple.com) and patch them for compatibility with iOS. 
- (optional) Run the script `./get_python_lua.sh`.  It will download the sources for  [python](https://github.com/holzschu/python_ios) and [lua](https://github.com/holzschu/lua_ios). 
- If you do *not* need Python, delete the `python_grp` folder, comment out the `#define FEAT_PYTHON` line in `ios_system.m` (if you are linking with iVim, also remove it from the `CFLAGS` of iVim).
- If you *do* need Python: open `../python_ios/libffi-3.2.1/libffi.xcodeproj/`, hit Build. It will create `libffi.a`. Click on Products, control-click on `libffi.a`, go to "Show in Finder". Copy it to the `../python_ios/` directory. 
- Same with Lua: if you do not need it, comment the  `#define FEAT_LUA` line in `ios_system.m`.
- If you need Tex, follow the instructions at https://github.com/holzschu/lib-tex, and link with the dynamic libraries created. Otherwise, comment out `#define TEX_COMMANDS`.
- Open the Xcode project `ios_system.xcodeproj` and hit build. This will create the `ios_system` framework, ready to be included in your own projects. Alternatively, drag `ios_system.xcodeproj` into you project, add `ios_system.framework` to your linked binaries and compile. 
