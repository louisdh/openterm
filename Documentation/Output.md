# Output

As commands run, they will typically output to their `stdout` and `stderr` pipes, which needs to be displayed to the user. Here, we describe how that data is decoded, parsed, and displayed.

First, some important notes:
* OpenTerm currently doesn't support the majority of terminal-like escape sequences. Lots of additional work still needs to be done here before it can support running things like shells, vim, etc.
* This document refers to escape sequences. If you are unfamiliar, read up on them [here](https://en.wikipedia.org/wiki/ANSI_escape_code)

## Receiving

When ios_system runs, its output is piped into the `CommandExecutor`, which then forwards it to the `CommandExecutorDelegate` as chunks of  `Data`. For commands that output multiple times before exiting, each output will be received as a separate chunk.

## Decoding

**important**: The data that is received may be in multiple chunks, as it is buffered by the system. Each chunk can be any size.

In order to make sense of the data, it must be decoded into a string. A naive implementation would just call `String.init(data: data, encoding: .utf8)`. However, not all data can be converted to UTF-8, and this initializer returns an optional value.

Characters in a UTF-8 string can be of various byte lengths, and since the data is buffered (as mentioned above), the data will most likely be split in a way that causes an unparsable character at the end.

It's up to the `Parser`, which does the decoding, to deal with this. The parser will iterate through all of the bytes in the data, pull out what valid characters it can, and store the remaining data until the next chunk is received.

## Parsing & Styling

Parsing takes each character that is decoded, and performs actions / modifies state as a result. At the end, an `NSAttributedString` will be created with the text to display to the user.

Output from commands that only output basic strings will mainly pass through this phase untouched.

As characters come in from a chunk of data, the `Parser` maintains an `NSMutableAttributedString`, and appends display characters to it. That attributed string is passed to its delegate when it's finished with a chunk.

Not all characters are display characters, however. Some make up escape sequences, and the `Parser` handles those as well, and doesn't display them to the user.

These escape sequences do things like the following:
- Setting foreground / background colors
- Adjusting the font style
- Moving the cursor around, and lots more.

As the `Parser` finds escape sequences, it will update its internal state, which affects the attributes in the `NSAttributedString` that is created.

## Displaying

Once an `NSAttributedString` is created, it is passed to the `Parser`'s delegate, which will append the text to the `TerminalView`'s `UITextView`.
