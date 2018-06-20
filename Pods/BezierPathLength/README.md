# [UI/NS]BezierPath + Length

[![Build Status](https://travis-ci.org/louisdh/bezierpath-length.svg?branch=master)](https://travis-ci.org/louisdh/bezierpath-length)
[![codecov](https://codecov.io/gh/louisdh/bezierpath-length/branch/master/graph/badge.svg)](https://codecov.io/gh/louisdh/bezierpath-length)
[![Code Climate](https://codeclimate.com/github/louisdh/bezierpath-length/badges/gpa.svg)](https://codeclimate.com/github/louisdh/bezierpath-length)
[![Swift](https://img.shields.io/badge/Swift-3.0.2-orange.svg?style=flat")](https://developer.apple.com/swift/)
![PodVersion](https://img.shields.io/cocoapods/v/BezierPathLength.svg)
![platform](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)
[![Twitter](https://img.shields.io/badge/Twitter-@LouisDhauwe-blue.svg?style=flat)](http://twitter.com/LouisDhauwe)

This project provides a simple API to get the length of either a ```UIBezierPath``` or ```NSBezierPath```. Example:

```swift
let rect = CGRect(origin: .zero, size: CGSize(width: 100, height: 300))
let path = UIBezierPath(ovalIn: rect)

// Length in pt.
let length = path.length
```


There's also an API for getting a point on a path at a certain percentage, example:

```swift
// CGPoint at 50% of path
let point = path.point(at: 0.5)
```


## Requirements

* iOS 8.0+ / macOS 10.9+ / tvOS 9.0+ / watchOS 2.0+
* Xcode 8.2+

## Installation

### [CocoaPods](http://cocoapods.org)

To install, add the following line to your ```Podfile```:

```ruby
pod 'BezierPathLength', '~> 1.0.0'
```

## How does it work?

The actual calculations are implemented on a ```CGPath``` extension, but a ```[UI/NS]BezierPath``` extension is available for convenience.

Any ```CGPath``` can be split into subpaths. Of which there are three types:

* Linear
* Quadratic curve
* Cubic curve
 
 
See [calculations.md](calculations.md) for a detailed mathematical explanation of how the length of these three can be calculated.

## License

This project is available under the MIT license. See the LICENSE file for more info.