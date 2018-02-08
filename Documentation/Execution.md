# Execution

This document describes the data flow of how a command goes from being typed by the user to being run by ios_system.

## Text entry

Text is entered into the `TerminalView`'s `UITextView`, and can be edited by the user. When the `return` key is pressed, a substring is taken of the text, from the prompt and through the last character, by the `TerminalView`.

That substring is sent to the `TerminalView`'s delegate for processing, assuming the substring was not empty.

## Command Parsing

The `TerminalView`'s delegate checks the command to see if it matches specific overridden commands ("help", "clear", etc). If it matches, it will execute those commands, and stop there.

Otherwise, it passes the command on to the `CommandExecutor`, which will execute the command.

## Command Executors

Each terminal instance has its own executor, which has an internal serial dispatch queue that it runs commands on.

Command executors have various methods for how they run commands. Each option is a class that conforms to the `CommandExecutorCommand` protocol. The command executor will decide which one to use, depending on the command it is told to run. (i.e. if the program name is a script, then it uses the `ScriptExecutorCommand`, but otherwise it uses the `SystemExecutorCommand`, which runs ios_system).

The command executor also contains `Pipe` objects for receiving output for commands. It forwards the output from those pipes to its delegate, which will display it in the UI.

## Command Execution

When the command finally gets to run (on the executor's dispatch queue), ios_system will be called, if it's a system command. The output from the command will be sent to the `CommandExecutor`'s delegate, and processed from there.

For information about output processing, see [Output](Output.md)
