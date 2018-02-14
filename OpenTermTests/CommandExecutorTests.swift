//
//  CommandExecutorTests.swift
//  OpenTermTests
//
//  Created by Ian McDowell on 2/13/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import XCTest
@testable import OpenTerm

class CommandExecutorTests: XCTestCase {

	private let workingDirectory = DocumentManager.shared.activeDocumentsFolderURL.appendingPathComponent("UnitTest")
	private let testFileNames = ["test.txt"]
	private let testFolderNames = ["Folder"]
	var executor: CommandExecutor!

	override func setUp() {
		super.setUp()

		executor = CommandExecutor()

		// Create a working directory
		try! FileManager.default.createDirectory(at: workingDirectory, withIntermediateDirectories: true, attributes: nil)
		executor.currentWorkingDirectory = workingDirectory

		// Put some test files in the directory
		for file in testFileNames {
			// Write the file name to a file by the same name
			try! file.write(to: workingDirectory.appendingPathComponent(file), atomically: true, encoding: .utf8)
		}

		// Put some test folders in the directory
		for folder in testFolderNames {
			try! FileManager.default.createDirectory(at: workingDirectory.appendingPathComponent(folder), withIntermediateDirectories: true, attributes: nil)
		}
	}

	override func tearDown() {
		super.tearDown()

		if FileManager.default.fileExists(atPath: workingDirectory.path) {
			try! FileManager.default.removeItem(at: workingDirectory)
		}
	}

	func testLS() {
		let (returnCode, stdout, stderr) = executor.run("ls")

		XCTAssertEqual(returnCode, 0)
		XCTAssertEqual(stderr.count, 0)

		guard let stdoutStr = String.init(data: stdout, encoding: .utf8) else {
			XCTFail("Unable to decode stdout")
			return
		}

		for name in testFileNames + testFolderNames {
			XCTAssert(stdoutStr.contains(name))
		}
	}

	func testCat() {
		for file in testFileNames {
			let (returnCode, stdout, stderr) = executor.run("cat \(file)")

			XCTAssertEqual(returnCode, 0)
			XCTAssertEqual(stderr.count, 0)

			guard let stdoutStr = String.init(data: stdout, encoding: .utf8) else {
				XCTFail("Unable to decode stdout")
				return
			}

			// Since file contains its name, the output should equal the file name
			XCTAssertEqual(stdoutStr, file)
		}
	}
}


extension CommandExecutor {

	func run(_ command: String) -> (returnCode: Int32, stdout: Data, stderr: Data) {

		var rc: Int32 = 0
		var out = Data()
		var err = Data()

		let sem = DispatchSemaphore.init(value: 0)

		let delegate = RunDelegate { returnCode, stdout, stderr in
			rc = returnCode
			out = stdout
			err = stderr

			sem.signal()
		}

		self.delegate = delegate
		self.dispatch(command)

		sem.wait()

		return (rc, out, err)
	}

	// CommandExecutorDelegate that calls back when process exits and outputs are closed
	private class RunDelegate: CommandExecutorDelegate {

		typealias ExecutorCallback = (_ returnCode: Int32, _ stdout: Data, _ stderr: Data) -> Void

		var callback: ExecutorCallback

		private var stdout = Data()
		private var stdoutReceivedEnd = false {
			didSet { callbackIfComplete() }
		}

		private var stderr = Data()
		private var stderrReceivedEnd = false {
			didSet { callbackIfComplete() }
		}

		private var returnCode: Int32 = 0
		private var hasCompleted = false {
			didSet { callbackIfComplete() }
		}

		init(_ callback: @escaping ExecutorCallback) {
			self.callback = callback
		}

		private let endOfTransmission = Parser.Code.endOfTransmission.rawValue.data(using: .utf8)!.first!

		private func callbackIfComplete() {
			if stdoutReceivedEnd && stderrReceivedEnd && hasCompleted {
				callback(self.returnCode, self.stdout, self.stderr)
			}
		}

		func commandExecutor(_ commandExecutor: CommandExecutor, receivedStdout stdout: Data) {
			self.stdout += stdout

			if stdout.last == endOfTransmission {
				self.stdout.removeLast()
				stdoutReceivedEnd = true
			}
		}
		func commandExecutor(_ commandExecutor: CommandExecutor, receivedStderr stderr: Data) {
			self.stderr += stderr

			if stderr.last == endOfTransmission {
				self.stderr.removeLast()
				stderrReceivedEnd = true
			}
		}
		func commandExecutor(_ commandExecutor: CommandExecutor, stateDidChange newState: CommandExecutor.State) {
			switch newState {
			case .idle:
				self.returnCode = Int32(commandExecutor.context[.status]!) ?? 0
				self.hasCompleted = true
			default:
				break
			}
		}
		func commandExecutor(_ commandExecutor: CommandExecutor, didChangeWorkingDirectory to: URL) {

		}
	}
}
