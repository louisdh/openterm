# Tab View

<p align="center">
  <a href="https://github.com/IMcD23/TiltedTabView">TiltedTabView</a> &bull;
  <b>TabView</b> &bull;
  <a href="https://github.com/IMcD23/InputAssistant">InputAssistant</a> &bull;
  <a href="https://github.com/IMcD23/Git">Git</a>
</p>

--------

A replacement for UITabViewController, which mimics Safari tabs on iOS

[![Build Status](http://img.shields.io/travis/IMcD23/TabView.svg)](https://travis-ci.org/IMcD23/TabView)
[![Version](https://img.shields.io/github/release/IMcD23/TabView.svg)](https://github.com/IMcD23/TabView/releases/latest)
![Package Managers](https://img.shields.io/badge/supports-Carthage-orange.svg)
[![Contact](https://img.shields.io/badge/contact-%40ian__mcdowell-3a8fc1.svg)](https://twitter.com/ian_mcdowell)

<img src="Resources/Screenshot.png" height="300"> 

# Requirements

* Xcode 9 or later
* iOS 11.0 or later

# Usage

There are two primary view controllers in this library: `TabViewController` and `TabViewContainerViewController`.
A `TabViewController` contains an array of tabs, a visible tab, and some methods to add and remove tabs. A `TabViewContainerViewController` contains `TabViewController`s.

It's not necessary to use a `TabViewContainerViewController`, but it's suggested, as it allows for split screen on iPad.

To get started, take a look at the public API for both classes, and look at the sample app for an example of how to use both.
At a minimum, you must subclass or instantiate a `TabViewController`, and add and remove tabs from it using its `activateTab(_:)` and `closeTab(_:)` methods.

# Installation

## Carthage
To install TabView using [Carthage](https://github.com/Carthage/Carthage), add the following line to your Cartfile:

```
github "IMcD23/TabView" "master"
```

## Submodule
To install TabView as a submodule into your git repository, run the following command:

```
git submodule add -b master https://github.com/IMcD23/TabView.git Path/To/TabView
git submodule update --init --recursive
```

Then, add the `.xcodeproj` in the root of the repository into your Xcode project, and add it as a build dependency.

## ibuild
A Swift static library of this project is also available for the ibuild build system. Learn more about ibuild [here](https://github.com/IMcD23/ibuild)

# Author
Created by [Ian McDowell](https://ianmcdowell.net)

# License
All code in this project is available under the license specified in the LICENSE file. However, since this project also bundles code from other projects, you are subject to those projects' licenses as well.
