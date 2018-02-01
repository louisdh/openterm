//
//  CommandExecutor.swift
//  OpenTerm
//
//  Created by Ian McDowell on 1/30/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import ios_system

protocol CommandExecutorDelegate: class {
    func commandExecutor(_ commandExecutor: CommandExecutor, receivedStdout stdout: String)
    func commandExecutor(_ commandExecutor: CommandExecutor, receivedStderr stderr: String)
    func commandExecutor(_ commandExecutor: CommandExecutor, didFinishDispatchWithExitCode exitCode: Int32)
}

// Exit status from an ios_system command
typealias ReturnCode = Int32

protocol CommandExecutorCommand {
    // Run the command
    func run(forExecutor executor: CommandExecutor) throws -> ReturnCode
}

/// Utility that executes commands serially to ios_system.
/// Has its own stdout/stderr, and passes output & results to its delegate.
class CommandExecutor {

    weak var delegate: CommandExecutorDelegate?

    /// Dispatch queue to serially run commands on.
    private let executionQueue = DispatchQueue(label: "CommandExecutor", qos: .userInteractive)
    /// Dispatch queue that delegate methods will be called on.
    private let delegateQueue = DispatchQueue(label: "CommandExecutor-Delegate", qos: .userInteractive)

    // Create new pipes for our own stdout/stderr
    private let stdout = Pipe()
    private let stderr = Pipe()
    fileprivate let stdout_file: UnsafeMutablePointer<FILE>?
    fileprivate let stderr_file: UnsafeMutablePointer<FILE>?

    /// Context from commands run by this executor
    private var context = CommandExecutionContext()

    init() {
        // Get file for stdout/stderr that can be written to
        stdout_file = fdopen(stdout.fileHandleForWriting.fileDescriptor, "w")
        stderr_file = fdopen(stderr.fileHandleForWriting.fileDescriptor, "w")

        // Call the following functions when data is written to stdout/stderr.
        stdout.fileHandleForReading.readabilityHandler = self.onStdout
        stderr.fileHandleForReading.readabilityHandler = self.onStderr
    }

    // Dispatch a new text-based command to execute.
    func dispatch(_ command: String) {
        executionQueue.async {
            let returnCode: ReturnCode
            do {
                let executorCommand = self.executorCommand(forCommand: command, inContext: self.context)
                returnCode = try executorCommand.run(forExecutor: self)
            } catch {
                returnCode = 1
                // If an error was thrown while running, send it to the stderr
                self.delegateQueue.async {
                    self.delegate?.commandExecutor(self, receivedStderr: error.localizedDescription)
                }
            }

            /// Save return code into the context
            self.context[.status] = "\(returnCode)"

            // Wait a bit to allow final stdout/stderr to get read.
            // TODO: This should not be needed, but it seems without it, output comes in after ios_system returns.
            self.delegateQueue.asyncAfter(deadline: .now() + 0.2) {
                self.delegate?.commandExecutor(self, didFinishDispatchWithExitCode: returnCode)
            }
        }
    }

    /// Take user-entered command, decide what to do with it, then return an executor command that will do the work.
    func executorCommand(forCommand command: String, inContext context: CommandExecutionContext) -> CommandExecutorCommand {
        // Apply context to the given command
        let command = context.apply(toCommand: command)

        // Separate in to command and arguments
        let components = command.components(separatedBy: .whitespaces)
        guard components.count > 0 else { return EmptyExecutorCommand() }
        let program = components[0]
        let args = Array(components[1..<components.endIndex])

        // Special case for scripts
        if Script.allNames.contains(program), let script = try? Script.named(program) {
            return ScriptExecutorCommand(script: script, arguments: args, context: context)
        }

        // Default case: Just execute the string itself
        return SystemExecutorCommand(command: command)
    }

    // Called when the stdout file handle is written to
    private func onStdout(_ stdout: FileHandle) {
        let data = stdout.availableData

        // Convert to byte array, init from cString so invalid characters are ignored and parsing continues.
        var byteArray = [UInt8](data)
        var str = String.init(cString: &byteArray)

        // TODO: This needs improvement, or data loss will occur on large buffered streams of data that arrive in chunks. (example: `curl -s wttr.in/london`)
        // Unless encoding is wrong, these invalid characters will be caused by data at the end of the stream
        // that was a UTF-8 code point that was only partially received and will arrive in the next output.
        //
        // There is currenly no buffering taking place here, so it's not possible to store the invalid data for later
        // to prepend to the next output.
        // Also, we don't know what the invalid data was, from the utf8 parsing API, so we wouldn't know what data to store.
        //
        // This current approach will display whatever utf-8 text can be parsed, and remove the rest.

        // Remove invalid characters that were found in the above string.
        str = str.replacingOccurrences(of: String(Character(Unicode.UTF8.decode(Unicode.UTF8.encodedReplacementCharacter))), with: "")

        delegateQueue.async {
            self.delegate?.commandExecutor(self, receivedStdout: str)
        }
    }

    // Called when the stderr file handle is written to
    private func onStderr(_ stderr: FileHandle) {
        let data = stderr.availableData
        
        // Convert to byte array, init from cString so invalid characters are ignored and parsing continues.
        var byteArray = [UInt8](data)
        var str = String.init(cString: &byteArray)

        // Remove invalid characters
        str = str.replacingOccurrences(of: String(Character(Unicode.UTF8.decode(Unicode.UTF8.encodedReplacementCharacter))), with: "")

        delegateQueue.async {
            self.delegate?.commandExecutor(self, receivedStderr: str)
        }
    }
}

/// Basic implementation of a command, run ios_system
struct SystemExecutorCommand: CommandExecutorCommand {

    let command: String

    func run(forExecutor executor: CommandExecutor) throws -> ReturnCode {
        // Set the stdout/stderr of the thread to the custom stdout/stderr.
        thread_stdout = executor.stdout_file
        thread_stderr = executor.stderr_file

        // Pass the value of the string to system, return its exit code.
        let returnCode = ios_system(command.utf8CString)

        // Flush stdout and stderr before returning, so all output is finished before marking command as complete.
        fflush(executor.stdout_file)
        fflush(executor.stderr_file)

        return returnCode
    }
}

/// No-op command to run.
struct EmptyExecutorCommand: CommandExecutorCommand {
    func run(forExecutor executor: CommandExecutor) throws -> ReturnCode {
        return 0
    }
}
