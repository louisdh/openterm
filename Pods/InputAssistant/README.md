# Input Assistant

<p align="center">
  <a href="https://github.com/IMcD23/TiltedTabView">TiltedTabView</a> &bull;
  <a href="https://github.com/IMcD23/TabView">TabView</a> &bull;
  <b>InputAssistant</b> &bull;
  <a href="https://github.com/IMcD23/Git">Git</a>
</p>

--------

This library is a view that shows custom auto-complete suggestions for your UITextField / UITextView.

[![Build Status](http://img.shields.io/travis/IMcD23/InputAssistant.svg)](https://travis-ci.org/IMcD23/InputAssistant)
[![Version](https://img.shields.io/github/release/IMcD23/InputAssistant.svg)](https://github.com/IMcD23/InputAssistant/releases/latest)
![Package Managers](https://img.shields.io/badge/supports-Carthage-orange.svg)
[![Contact](https://img.shields.io/badge/contact-%40ian__mcdowell-3a8fc1.svg)](https://twitter.com/ian_mcdowell)

<img src="Resources/Keyboard.png" height="300"> <img src="Resources/Keyboard_iPad.png" height="300"> 

# Requirements

* Xcode 9 or later
* iOS 10.0 or later

# Usage

This library provides an `InputAssistantView` class, that is designed to be set as the `inputAccessoryView` of a UITextView or UITextField.

It provides three areas that you can customize.
- Suggestions - A scrollable set of text suggestions.
- Leading/Trailing actions - tappable buttons on either side of the suggestions.
- Empty text - Optional text that can be displayed when there are no suggestions.

Use the `InputAssistantViewDataSource` protocol that allows you to do this customization.

To react to a suggestion being tapped, conform to the `InputAssistantViewDelegate` protocol.

# Installation

## Carthage
To install InputAssistant using [Carthage](https://github.com/Carthage/Carthage), add the following line to your Cartfile:

```
github "IMcD23/InputAssistant" "master"
```

## Submodule
To install InputAssistant as a submodule into your git repository, run the following command:

```
git submodule add -b master https://github.com/IMcD23/InputAssistant.git Path/To/InputAssistant
git submodule update --init --recursive
```

Then, add the `.xcodeproj` in the root of the repository into your Xcode project, and add it as a build dependency.

## ibuild
A Swift static library of this project is also available for the ibuild build system. Learn more about ibuild [here](https://github.com/IMcD23/ibuild)

# Author
Created by [Ian McDowell](https://ianmcdowell.net)

# License
All code in this project is available under the license specified in the LICENSE file. However, since this project also bundles code from other projects, you are subject to those projects' licenses as well.
