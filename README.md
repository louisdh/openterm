<p align="center">
<img src="readme-resources/hero.png" alt="Terminal for iOS">
</p>

<h1 align="center">OpenTerm</h1>

<p align="center">
<a href="https://itunes.apple.com/app/terminal/id1323205755?mt=8&at=1010lII4"><img src="readme-resources/app_store_badge.svg" alt="Download on the App Store"/></a>
<br><span align="center">(Previously called Terminal for iOS)</span>

</p>

<p align="center">
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" alt="Swift"/></a>

<img src="https://img.shields.io/badge/Platform-iOS%2011.0+-lightgrey.svg" alt="Platform: iOS">
<a href="https://travis-ci.org/louisdh/terminal"><img src="https://travis-ci.org/louisdh/terminal.svg?branch=master" alt="Build Status"/></a>
<br>
<a href="http://twitter.com/LouisDhauwe"><img src="https://img.shields.io/badge/Twitter-@LouisDhauwe-blue.svg?style=flat" alt="Twitter"/></a>
</p>

## About
This is a sandboxed command line interface for iOS. 


Commands included:

|          |          |          |          |
| ---- | ---- | ---- | ---- |
|awk|cat|cd|chflags|chksum|
|clear|compress|cp|curl|date|
|du|echo|egrep|env|fgrep|
|grep|gunzip|gzip|help|link|
|ln|ls|mkdir|mv|printenv|
|pwd|readlink|rm|rmdir|scp|
|sed|setenv|sftp|stat|sum|
|tar|touch|tr|uname|uncompress|
|unsetenv|uptime|wc|whoami|


## Dependencies
This project uses a modified version of [ios_system](https://github.com/holzschu/ios_system), which requires OpenSSL. For convenience both of these are included in the `Dependencies` folder.

## Running
Open `OpenTerm.xcworkspace`, change the bundle identifier to an identifier linked to your Apple developer account in order to run. Build using the `OpenTerm` scheme. Please note that with the current setup you can only build for arm64 (so no iOS simulator).

## License

This project is available under the MIT license. See the LICENSE file for more info.
