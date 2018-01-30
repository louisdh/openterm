# InputAssistant

This library is a view that shows custom auto-complete suggestions for your UITextField / UITextView.

<img src="Resources/Keyboard.png" height="300"> <img src="Resources/Keyboard_iPad.png" height="300">

## Installation

### Carthage
This library is available via [Carthage](https://github.com/Carthage/Carthage). To install, add the following to your Cartfile:
```
github IMcD23/InputAssistant
```
### Submodule
You can also add this project as a git submodule.
```
git submodule add https://github.com/IMcD23/InputAssistant path/to/InputAssistant
```
Run the command above, then drag the `InputAssistant.xcodeproj` into your Xcode project and add it as a build dependency.

### ibuild
A Swift static library of this project is also available for the ibuild build system. Learn more about ibuild [here](https://github.com/IMcD23/ibuild)

## Usage
This library provides an `InputAssistantView` class, that is designed to be set as the `inputAccessoryView` of a UITextView or UITextField.

It provides three areas that you can customize.
- Suggestions - A scrollable set of text suggestions.
- Leading/Trailing actions - tappable buttons on either side of the suggestions.
- Empty text - Optional text that can be displayed when there are no suggestions.

Use the `InputAssistantViewDataSource` protocol that allows you to do this customization.

To react to a suggestion being tapped, conform to the `InputAssistantViewDelegate` protocol.

## Example
Take a look at the [Sample App](Sample) for an example of the implementation.
