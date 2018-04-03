<p align="center">
<img src="readme-resources/hero@2x.png" style="max-height: 300px;" alt="HueKit for iOS">
</p>

<p align="center">
<a href="https://travis-ci.org/louisdh/huekit"><img src="https://travis-ci.org/louisdh/huekit.svg?branch=master" style="max-height: 300px;" alt="Build Status"/></a>
<br>
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" style="max-height: 300px;" alt="Swift"/></a>
<a href="https://cocoapods.org/pods/HueKit"><img src="https://img.shields.io/cocoapods/v/HueKit.svg" style="max-height: 300px;" alt="Pod Version"/></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4bc51d.svg?style=flat" style="max-height: 300px;" alt="Carthage Compatible"/></a>
<img src="https://img.shields.io/badge/platform-iOS-lightgrey.svg" style="max-height: 300px;" alt="Platform: iOS">
<br>
<a href="http://twitter.com/LouisDhauwe"><img src="https://img.shields.io/badge/Twitter-@LouisDhauwe-blue.svg?style=flat" style="max-height: 300px;" alt="Twitter"/></a>
<a href="https://paypal.me/louisdhauwe"><img src="https://img.shields.io/badge/Donate-PayPal-green.svg?style=flat" alt="Donate via PayPal"/></a>
</p>

<p align="center">
<img src="readme-resources/example.gif" style="max-height: 1480px;" alt="HueKit for iOS">
</p>


## About
HueKit is a UI framework for iOS that provides components and utilities for building color pickers. Since each app may want a custom color picker, the design of this framework is geared towards reusability and allows for great customization.

### Components
All components are marked `open`, so they can be subclassed. Also, all components are marked `@IBDesignable`, so they can be previewed in Interface Builder. Components that provide user interaction are subclassed from `UIControl`, you can observe a change in value by using `@IBAction`.

#### ColorBarPicker
![](readme-resources/components/ColorBarPicker.png)

#### ColorBarView
![](readme-resources/components/ColorBarView.png)

#### ColorIndicatorView
![](readme-resources/components/ColorIndicatorView.png)

#### ColorSquarePicker
![](readme-resources/components/ColorSquarePicker.png)

#### ColorSquareView
![](readme-resources/components/ColorSquareView.png)

#### SourceColorView
![](readme-resources/components/SourceColorView.png)


## Installation

### [CocoaPods](http://cocoapods.org)

To install, add the following line to your ```Podfile```:

```ruby
pod 'HueKit', '~> 1.0'
```

### [Carthage](https://github.com/Carthage/Carthage)
To install, add the following line to your ```Cartfile```:

```ruby
github "louisdh/huekit" ~> 1.0
```
Run ```carthage update``` to build the framework and drag the built ```HueKit.framework``` into your Xcode project.



## Requirements

* iOS 10.0+
* Xcode 9.0+

## Todo 

- [ ] Add tests
- [ ] Add documentation
 
## License

This project is available under the MIT license. See the LICENSE file for more info.
