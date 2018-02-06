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

	// The "End of transmission" control code. When received by stdout pipe, the didFinishDispatchWithExitCode delegate method is called.
	private static let endCtrlCode = Character("\u{0004}")

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
					self.delegate?.commandExecutor(self, receivedStderr: error.localizedDescription)
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
			self.stdout_pipe.fileHandleForWriting.write(String(CommandExecutor.endCtrlCode).data(using: .utf8)!)
		}
		stdout = push_stdout
		stderr = push_stderr
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
	private var stdoutBuffer = Data()
	// Called when the stdout file handle is written to
	private func onStdout(_ stdout: FileHandle) {
		var str = self.decodeUTF8(fromData: stdout.availableData, buffer: &stdoutBuffer)

		var hadEnd: Bool = false
		if let index = str.index(of: CommandExecutor.endCtrlCode) {
			str = String(str[..<index])
			hadEnd = true
		}

		delegateQueue.async {
			if !str.isEmpty {
				self.delegate?.commandExecutor(self, receivedStdout: str)
			}
			if hadEnd {
				let lastStatus = Int32(self.context[.status] ?? "0") ?? 0
				self.delegate?.commandExecutor(self, didFinishDispatchWithExitCode: lastStatus)
			}
		}
	}

	private var stderrBuffer = Data()
	// Called when the stderr file handle is written to
	private func onStderr(_ stderr: FileHandle) {
		let str = self.decodeUTF8(fromData: stderr.availableData, buffer: &stderrBuffer)

		delegateQueue.async {
			self.delegate?.commandExecutor(self, receivedStderr: str)
		}
	}

	private func decodeUTF8(fromData data: Data, buffer: inout Data) -> String {
		let data = buffer + data

		// Parse what we can from the previous leftover and the new data.
		let (str, leftover) = self.decodeUTF8(fromData: data)

		// There are two reasons we could get leftover data:
		// - An invalid character was found in the middle of the string
		// - An invalid character was found at the end
		//
		// We only want to keep data for parsing in the second case, since
		// the parsing most likely failed due to missing data that will come
		// in the next read from the pipe.
		// The max size for the stuff we care about is the width of a utf8 code unit.
		if leftover.count <= UTF8.CodeUnit.bitWidth {
			buffer = leftover
		} else {
			buffer = Data()
		}

		return str
	}

	/// Decode UTF-8 string from the given data.
	/// This is a custom implementation that decodes what characters it can then returns whatever it can't,
	/// which is necessary since data can come in arbitrarily-sized chunks of bytes, with characters split
	/// across multiple chunks.
	/// The first time decoding fails, all of the rest of the data will be returned.
	private func decodeUTF8(fromData data: Data) -> (decoded: String, remaining: Data) {
		let byteArray = [UInt8](data)

		var utf8Decoder = UTF8()
		var str = ""
		var byteIterator = byteArray.makeIterator()
		var decodedByteCount = 0
		Decode: while true {
			switch utf8Decoder.decode(&byteIterator) {
			case .scalarValue(let v):
				str.append(Character(v))
				decodedByteCount += UTF8.encode(v)!.count
			case .emptyInput, .error:
				break Decode
			}
		}

		let remaining = Data.init(bytes: byteArray.suffix(from: decodedByteCount))
		return (str, remaining)
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
		return ios_system(command.utf8CString)
	}
}

/// No-op command to run.
struct EmptyExecutorCommand: CommandExecutorCommand {
	func run(forExecutor executor: CommandExecutor) throws -> ReturnCode {
		return 0
	}
}
