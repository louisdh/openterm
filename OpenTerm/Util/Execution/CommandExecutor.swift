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

/// Utility that executes commands serially to ios_system.
/// Has its own stdout/stderr, and passes output & results to its delegate.
class CommandExecutor {

    weak var delegate: CommandExecutorDelegate?

    /// Dispatch queue to serially run commands on.
    private let queue = DispatchQueue.init(label: "CommandExecutor", qos: .userInteractive)

    private let stdout: Pipe
    private let stdout_file: UnsafeMutablePointer<FILE>?
    private let stderr: Pipe
    private let stderr_file: UnsafeMutablePointer<FILE>?

    init() {
        // Create a new pipe for stdout/stderr, and get FILE pointers for writing to them
        stdout = Pipe()
        stdout_file = fdopen(stdout.fileHandleForWriting.fileDescriptor, "w")
        stderr = Pipe()
        stderr_file = fdopen(stderr.fileHandleForWriting.fileDescriptor, "w")

        // Call the following functions when data is written.
        stdout.fileHandleForReading.readabilityHandler = self.onStdout
        stderr.fileHandleForReading.readabilityHandler = self.onStderr
    }

    // Dispatch a new command to execute.
    func dispatch(_ command: String) {
        queue.async {
            let returnCode = self.system(command)

            // Wait a bit to allow final stdout/stderr to get read. TODO: This should not be needed, but it is.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.delegate?.commandExecutor(self, didFinishDispatchWithExitCode: returnCode)
            }
        }
    }

    // Dispatch a set of commands to run serially. If a command returns a non-zero exit code, subsequent commands do not run.
    func dispatch(_ commands: [String]) {
        queue.async {
            var returnCode: Int32 = 0
            for command in commands {
                returnCode = self.system(command)
                if returnCode != 0 {
                    break
                }
            }

            // Wait a bit to allow final stdout/stderr to get read. TODO: This should not be needed, but it is.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.delegate?.commandExecutor(self, didFinishDispatchWithExitCode: returnCode)
            }
        }
    }

    // Run ios_system, with stdout/stderr set to ours.
    private func system(_ command: String) -> Int32 {
        dispatchPrecondition(condition: .onQueue(queue))

        thread_stdout = self.stdout_file
        thread_stderr = self.stderr_file
        return ios_system(command.utf8CString)
    }

    // Called when the stdout file handle is written to
    private func onStdout(_ stdout: FileHandle) {
        guard let str = String.init(data: stdout.availableData, encoding: .utf8) else { return }
        DispatchQueue.main.async {
            self.delegate?.commandExecutor(self, receivedStdout: str)
        }
    }

    // Called when teh stderr file handle is written to
    private func onStderr(_ stderr: FileHandle) {
        guard let str = String.init(data: stderr.availableData, encoding: .utf8) else { return }
        DispatchQueue.main.async {
            self.delegate?.commandExecutor(self, receivedStderr: str)
        }
    }
}
