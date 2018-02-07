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
	func commandExecutor(_ commandExecutor: CommandExecutor, receivedStdout stdout: Data)
	func commandExecutor(_ commandExecutor: CommandExecutor, receivedStderr stderr: Data)
	func commandExecutor(_ commandExecutor: CommandExecutor, didChangeWorkingDirectory to: URL)
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

	// The current working directory for this executor.
	var currentWorkingDirectory: URL {
		didSet {
			delegateQueue.async {
				self.delegate?.commandExecutor(self, didChangeWorkingDirectory: self.currentWorkingDirectory)
			}
		}
	}

	/// Dispatch queue to serially run commands on.
	private static let executionQueue = DispatchQueue(label: "CommandExecutor", qos: .userInteractive)
	/// Dispatch queue that delegate methods will be called on.
	private let delegateQueue = DispatchQueue(label: "CommandExecutor-Delegate", qos: .userInteractive)

	// Create new pipes for our own stdout/stderr
	private let stdout_pipe = Pipe()
	private let stderr_pipe = Pipe()
	fileprivate let stdout_file: UnsafeMutablePointer<FILE>?
	fileprivate let stderr_file: UnsafeMutablePointer<FILE>?

	/// Context from commands run by this executor
	private var context = CommandExecutionContext()

	init() {
		self.currentWorkingDirectory = DocumentManager.shared.activeDocumentsFolderURL

		// Get file for stdout/stderr that can be written to
		stdout_file = fdopen(stdout_pipe.fileHandleForWriting.fileDescriptor, "w")
		stderr_file = fdopen(stderr_pipe.fileHandleForWriting.fileDescriptor, "w")

		// Call the following functions when data is written to stdout/stderr.
		stdout_pipe.fileHandleForReading.readabilityHandler = self.onStdout
		stderr_pipe.fileHandleForReading.readabilityHandler = self.onStderr
	}

	// Dispatch a new text-based command to execute.
	func dispatch(_ command: String) {
		let push_stdout = stdout
		let push_stderr = stderr

		CommandExecutor.executionQueue.async {
			// Set the executor's CWD as the process-wide CWD
			DocumentManager.shared.currentDirectoryURL = self.currentWorkingDirectory
			stdout = self.stdout_file!
			stderr = self.stderr_file!
			let returnCode: ReturnCode
			do {
				let executorCommand = self.executorCommand(forCommand: command, inContext: self.context)
				returnCode = try executorCommand.run(forExecutor: self)
			} catch {
				returnCode = 1
				// If an error was thrown while running, send it to the stderr
				self.delegateQueue.async {
					self.delegate?.commandExecutor(self, receivedStderr: error.localizedDescription.data(using: .utf8)!)
				}
			}

			// Save the current process-wide CWD to our value
			let newDirectory = DocumentManager.shared.currentDirectoryURL
			if newDirectory != self.currentWorkingDirectory {
				self.currentWorkingDirectory = newDirectory
			}
			// Reset the process-wide CWD back to documents folder
			DocumentManager.shared.currentDirectoryURL = DocumentManager.shared.activeDocumentsFolderURL

			// Save return code into the context
			self.context[.status] = "\(returnCode)"

			// Write the end code to stdout_pipe
			// TODO: Also need to send to stderr?
			self.stdout_pipe.fileHandleForWriting.write(Parser.Code.endOfTransmission.rawValue.data(using: .utf8)!)

			stdout = push_stdout
			stderr = push_stderr
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
		delegateQueue.async {
			self.delegate?.commandExecutor(self, receivedStdout: data)
		}
	}

	// Called when the stderr file handle is written to
	private func onStderr(_ stderr: FileHandle) {
		let data = stderr.availableData
		delegateQueue.async {
			self.delegate?.commandExecutor(self, receivedStderr: data)
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

		// Flush pipes to make sure all data is read
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
