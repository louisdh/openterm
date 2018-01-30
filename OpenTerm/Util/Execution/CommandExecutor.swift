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
    func run() throws -> ReturnCode
}

/// Utility that executes commands serially to ios_system.
/// Has its own stdout/stderr, and passes output & results to its delegate.
class CommandExecutor {

    weak var delegate: CommandExecutorDelegate?

    /// Dispatch queue to serially run commands on.
    private let queue = DispatchQueue.init(label: "CommandExecutor", qos: .userInteractive)

    // Create new pipes for our own stdout/stderr
    private static let stdout = Pipe()
    private static let stderr = Pipe()
    fileprivate static let stdout_file = fdopen(CommandExecutor.stdout.fileHandleForWriting.fileDescriptor, "w")
    fileprivate static let stderr_file = fdopen(CommandExecutor.stderr.fileHandleForWriting.fileDescriptor, "w")

    init() {
        // Call the following functions when data is written to stdout/stderr.
        CommandExecutor.stdout.fileHandleForReading.readabilityHandler = self.onStdout
        CommandExecutor.stderr.fileHandleForReading.readabilityHandler = self.onStderr
    }

    // Dispatch a new text-based command to execute.
    func dispatch(_ command: String) {
        queue.async {
            let returnCode: ReturnCode
            do {
                let executorCommand = CommandExecutor.executorCommand(forCommand: command)
                returnCode = try executorCommand.run()
            } catch {
                returnCode = 1
                // If an error was thrown while running, send it to the stderr
                DispatchQueue.main.async {
                    self.delegate?.commandExecutor(self, receivedStderr: error.localizedDescription)
                }
            }

            // Wait a bit to allow final stdout/stderr to get read.
            // TODO: This should not be needed, but it seems without it, output comes in after ios_system returns.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.delegate?.commandExecutor(self, didFinishDispatchWithExitCode: returnCode)
            }
        }
    }

    /// Take user-entered command, decide what to do with it, then return an executor command that will do the work.
    static func executorCommand(forCommand command: String) -> CommandExecutorCommand {
        // Separate in to command and arguments
        let components = command.components(separatedBy: .whitespaces)
        guard components.count > 0 else { return EmptyExecutorCommand() }
        let program = components[0]
        let args = Array(components[1..<components.endIndex])

        // Special case for scripts
        if Script.allNames.contains(program), let script = try? Script.named(program) {
            return ScriptExecutorCommand(script: script, arguments: args)
        }

        // Default case: Just execute the string itself
        return SystemExecutorCommand(command: command)
    }

    // Called when the stdout file handle is written to
    private func onStdout(_ stdout: FileHandle) {
        guard let str = String.init(data: stdout.availableData, encoding: .utf8), !str.isEmpty else { return }
        DispatchQueue.main.async {
            self.delegate?.commandExecutor(self, receivedStdout: str)
        }
    }

    // Called when the stderr file handle is written to
    private func onStderr(_ stderr: FileHandle) {
        guard let str = String.init(data: stderr.availableData, encoding: .utf8), !str.isEmpty else { return }
        DispatchQueue.main.async {
            self.delegate?.commandExecutor(self, receivedStderr: str)
        }
    }
}

/// Basic implementation of a command, run ios_system
struct SystemExecutorCommand: CommandExecutorCommand {

    let command: String

    func run() throws -> ReturnCode {
        // Set the stdout/stderr of the thread to the custom stdout/stderr.
        thread_stdout = CommandExecutor.stdout_file
        thread_stderr = CommandExecutor.stderr_file

        // Pass the value of the string to system, return its exit code.
        let returnCode = ios_system(command.utf8CString)
        // Flush stdout and stderr before returning, so all output is finished before marking command as complete.
        fflush(CommandExecutor.stdout_file)
        fflush(CommandExecutor.stderr_file)
        return returnCode
    }
}

/// No-op command to run.
struct EmptyExecutorCommand: CommandExecutorCommand {
    func run() throws -> ReturnCode {
        return 0
    }
}
