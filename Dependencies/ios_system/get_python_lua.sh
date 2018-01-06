#! /bin/bash

# Optional: get also sources for Python and Lua:
( # Python_ios
cd "${BASH_SOURCE%/*}/.."
git clone https://github.com/holzschu/python_ios
cd "python_ios"
sh ./getPackages.sh
)
( # lua_ios 
cd "${BASH_SOURCE%/*}/.."
git clone https://github.com/holzschu/lua_ios
cd "lua_ios"
sh ./get_lua_source.sh
)


