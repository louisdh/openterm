<p align="center">
  <a href="https://github.com/louisdh/lioness">Lioness</a> &bull;
  <b> Cub </b> &bull;
  <a href="https://github.com/louisdh/savannakit">SavannaKit</a>
</p>

<p align="center">
<img src="docs/resources/readme/logo@2x.png" alt="Cub Logo" height="200px">
</p>

<h1 align="center">The Cub Programming Language</h1>

<p align="center">
<a href="https://travis-ci.org/louisdh/cub"><img src="https://travis-ci.org/louisdh/cub.svg?branch=master" alt="Travis build status"/></a>
<a href="https://codecov.io/gh/louisdh/cub"><img src="https://codecov.io/gh/louisdh/cub/branch/master/graph/badge.svg" alt="Codecov"/></a>
<br>
<img src="https://img.shields.io/badge/version-0.7.3-blue.svg" style="max-height: 300px;" alt="version 0.7.3">
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4bc51d.svg?style=flat" style="max-height: 300px;" alt="Carthage Compatible"/></a>
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat" style="max-height: 300px;" alt="Swift"/></a>
<img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-lightgrey.svg" style="max-height: 300px;" alt="Platform: iOS macOS tvOS watchOS">
<img src="https://img.shields.io/badge/extension-.cub-FF9C27.svg" style="max-height: 300px;" alt="Extension: .cub">
<br>
<a href="http://twitter.com/LouisDhauwe"><img src="https://img.shields.io/badge/Twitter-@LouisDhauwe-blue.svg?style=flat" style="max-height: 300px;" alt="Twitter"/></a>
<a href="https://paypal.me/louisdhauwe"><img src="https://img.shields.io/badge/Donate-PayPal-green.svg?style=flat" alt="Donate via PayPal"/></a>
</p>

Cub is an **interpreted** scripting language inspired by Swift. This project includes a lexer, parser, compiler and interpreter. All of these are 100% written in Swift without dependencies. 

Cub was derived from [Lioness](https://github.com/louisdh/lioness) (my first programming language).

The standard library (abbreviated: stdlib) contains basic functions for number manipulation, including: max/min, ceil, floor, trigonometry, etc.


## Source examples
The following Cub code calculates factorials recursively:

```swift
func factorial(x) returns {
	
    if x > 1 {
        return x * factorial(x - 1)
    }
	
    return 1
}

a = factorial(5) // a = 120
```

The following Cub code uses a ```do times``` loop:

```swift
a = 1
n = 10
do n times {
    a += a
}
// a = 1024
```

*More examples can be found [here](Source%20examples).*

## External functions
An important feature Cub has is the ability to define external functions. These functions are implemented in native code (for example Swift) and thus allows Cub to call native code.

An external function pauses the interpreter, executes the native code, and resumes the interpreter when the native code is executed.

The following example implements a print function:

```swift
let runner = Runner(logDebug: true, logTime: true)
		
runner.registerExternalFunction(name: "print", argumentNames: ["input"], returns: true) { (arguments, callback) in
			
	for (name, arg) in arguments {
		print(arg)
	}
			
	callback(nil)
}

```

External functions are called like any other global functions in Cub, the print function from the example above could be called like this:

```swift
print("Hello world")
```


## Features

* Minimalistic, yet expressive, syntax
* No type system, language is dynamic
* 5 basic operators: ```+```, ```-```, ```/```, ```*``` and ```^```
	* ```^``` means "to the power of", e.g. ```2^10``` equals 1024
	* all operators have a shorthand, e.g. ```+=``` for ```+```
* Numbers
	* All numbers are floating point 
* Booleans
	* Can be evaluated from comparison
	* Can be defined by literal: ```true``` or ```false``` 
* Strings
	* Can be concatenated with the + operator 
* Arrays
	* Can contain any type, including other arrays  
* Functions
	* Supports parameters, returning and recursion 
	* Can be declared inside other functions
* Structs
	* Can contain any type, including other structs  
* Loops
	* ```for```
	* ```while```
	* ```do times```
	* ```repeat while```
	* ```break```
	* ```continue```
* ```if``` / ```else``` / ```else if``` statements

## Running
Since the project does not rely on any dependencies, running it requires no setup. 

### macOS
Open ```Cub.xcworkspace``` (preferably in the latest non-beta version of Xcode) and run the ```macOS Example``` target. The example will run the code in ```A.lion```. The output will be printed to the console.

## Installing framework
 
### Using Swift Package Manager

Add to your `Package.swift` file's `dependencies` section:

```swift
.Package(url: "https://github.com/louisdh/cub.git",
		         majorVersion: 0, minor: 7)
```

### Using [CocoaPods](http://cocoapods.org)

Add the following line to your ```Podfile```:

```ruby
pod 'Cub', '~> 0.7'
```

### Using [Carthage](https://github.com/Carthage/Carthage)
Add the following line to your ```Cartfile```:

```ruby
github "louisdh/cub" ~> 0.7
```
Run ```carthage update``` to build the framework and drag the built ```Cub.framework``` into your Xcode project.


## Standard Library
*Please note: Cub is currently in beta*

The Standard Library is currently under active development. There currently is no one document with everything from the stdlib. The best place to look for what's available is in [the source files](Sources/Cub/Standard%20Library/Sources/).

## Roadmap
- [x] Structs
- [ ] Completion suggestions  (given an incomplete source string and insertion point)
- [ ] Breakpoint support in interpreter
- [ ] Stdlib documentation (Dash?)
- [ ] Compiler warnings
- [ ] Compiler optimizations
- [x] Faster Lexer (without regex)
- [x] Support emoticons for identifier names
- [ ] ```guard``` statement
- [ ] A lot more unit tests
- [x] Linux support

## Xcode file template
Cub source files can easily be created with Xcode, see [XcodeTemplate.md](XcodeTemplate.md) for instructions.


## Architecture
A detailed explanation of the project's architecture can be found [here](docs/Architecture.md).

## License

This project is available under the MIT license. See the LICENSE file for more info.
