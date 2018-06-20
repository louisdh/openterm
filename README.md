<p align="center">
<img src="readme-resources/hero.png" alt="Terminal for iOS">
</p>

<h1 align="center">OpenTerm</h1>

<p align="center">
<a href="https://itunes.apple.com/app/terminal/id1323205755?mt=8&at=1010lII4"><img src="readme-resources/app_store_badge.svg" alt="Download on the App Store"/></a>
<br><span align="center">(Previously called Terminal for iOS)</span>

</p>

<p align="center">
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat" alt="Swift"/></a>

<img src="https://img.shields.io/badge/Platform-iOS%2011.0+-lightgrey.svg" alt="Platform: iOS">
<a href="https://travis-ci.org/louisdh/openterm"><img src="https://travis-ci.org/louisdh/openterm.svg?branch=master" alt="Build Status"/></a>
<br>
<a href="http://twitter.com/LouisDhauwe"><img src="https://img.shields.io/badge/Twitter-@LouisDhauwe-blue.svg?style=flat" alt="Twitter"/></a>
<a href="https://paypal.me/louisdhauwe"><img src="https://img.shields.io/badge/Donate-PayPal-green.svg?style=flat" alt="Donate via PayPal"/></a>
</p>

## About
OpenTerm is a sandboxed command line interface for iOS. 


Commands included:

|            |            |            |            |
| ---------- | ---------- | ---------- | ---------- |
| awk        | cat        | cd         | chflags    |
| chksum     | clear      | compress   | cp         |
| credits    | cub        | curl       | date       |
| dig        | du         | echo       | egrep      |
| env        | fgrep      | grep       | gunzip     |
| gzip       | help       | host       | link       |
| ln         | ls         | mkdir      | mv         |
| nc         | nslookup   | open-url   | pbcopy     |
| pbpaste    | ping       | printenv   | pwd        |
| readlink   | rlogin     | rm         | rmdir      |
| say        | scp        | sed        | setenv     |
| sftp       | share      | sleep      | ssh        |
| ssh-keygen | stat       | sum        | tar        |
| tee        | telnet     | touch      | tr         |
| uname      | uncompress | unlink     | unsetenv   |
| uptime     | wc         | whoami     |            |

## Dependencies
To set up dependencies, run `bootstrap.sh`.

## Running
Open `OpenTerm.xcworkspace`, change the bundle identifier to an identifier linked to your Apple developer account in order to run. Build using the `OpenTerm` scheme. 

### Running on device
To run on a device, you will have to run `resign-frameworks.sh`, but first change `iPhone Developer: Louis D'hauwe (5U7B95VS8G)` with the name of your own certificate. 

## License

OpenTerm is available under the GPLv2 (or later) and the MPLv2 license.

See [COPYING](./COPYING) for more license info.
