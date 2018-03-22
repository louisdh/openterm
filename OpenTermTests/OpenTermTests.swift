//
//  OpenTermTests.swift
//  OpenTermTests
//
//  Created by Louis D'hauwe on 07/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import XCTest
@testable import OpenTerm
import ios_system

class OpenTermTests: XCTestCase {
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		
		initializeEnvironment()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
		
    }
	
	/// Test to make sure commands don't accidentally get added or removed.
	func testAvailableCommands() {
		
		let terminalVC = TerminalViewController()
		
		let commands = terminalVC.availableCommands()
		
		let expectedCommands = ["awk", "cat", "cd", "chflags", "chksum", "clear", "compress", "cp", "curl", "date", "dig", "du", "echo", "egrep", "env", "fgrep", "grep", "gunzip", "gzip", "help", "host", "link", "ln", "ls", "mkdir", "mv", "nc", "nslookup", "open-url", "pbcopy", "pbpaste", "ping", "printenv", "pwd", "readlink", "rlogin", "rm", "rmdir", "scp", "sed", "setenv", "sftp", "share", "ssh", "ssh-keygen", "stat", "sum", "tar", "tee", "telnet", "touch", "tr", "uname", "uncompress", "unlink", "unsetenv", "uptime", "wc", "whoami"]
		
		XCTAssertEqual(commands, expectedCommands)
		
	}
	
	func testIfAllCommandsWork() {
		
		let terminalVC = TerminalViewController()
		
		let commands = terminalVC.availableCommands()
		
		for command in commands {
			
			// These commands enter the interactive mode of the terminal,
			// so ignore these for now.
			let interactiveCommands = ["cat", "chksum", "dig", "nslookup", "gunzip", "gzip", "pbcopy", "pbpaste", "sed", "share", "ssh-keygen", "sum", "tee", "telnet", "wc"]
			
			if interactiveCommands.contains(command) {
				continue
			}
			
			testIfCommandWorks(command: command)

		}
		
	}
	
	// Keep a strong pointer to executors, so they stay in memory.
	var executors = [CallbackCommandExecutor]()
	
	func testIfCommandWorks(command: String) {

		print("test \(command)")

		let terminalView = TerminalView()

		let deviceName = terminalView.deviceName
		
		let delayExpectation = expectation(description: "Waiting for \(command)")
		
		let notFoundOutput = "\(deviceName): \(command): command not found\n\(deviceName): "
		
		let executor = CallbackCommandExecutor(commandStr: command, terminalView: terminalView, callback: {
			
			let output = terminalView.textView.text
			XCTAssertNotEqual(output, notFoundOutput)
			
			print("fullfill \(command)")
			
			delayExpectation.fulfill()
			
		})
	
		executors.append(executor)
		
		wait(for: [delayExpectation], timeout: 2)
		
	}
	
    func testCURL() {
		
		let terminalView = TerminalView()

		let delegator = TerminalViewDelegator(terminalView: terminalView)
		
		terminalView.delegate = delegator
		
		delegator.didEnterCommand("curl")
		
		let deviceName = terminalView.deviceName
		
		let delayExpectation = expectation(description: "Waiting for command")

		let expectedOutput = "\(deviceName): curl: try \'curl --help\' or \'curl --manual\' for more information\n\(deviceName): "
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			
			let output = terminalView.textView.text
			
			XCTAssertEqual(output, expectedOutput)
			
			delayExpectation.fulfill()
		}

		waitForExpectations(timeout: 2)
		
    }
	
}

class TerminalViewDelegator: TerminalViewDelegate {
	
	let terminalView: TerminalView
	
	init(terminalView: TerminalView) {
		self.terminalView = terminalView
	}
	
	func commandDidEnd() {

	}
	
	func didEnterCommand(_ command: String) {
		
		processCommand(command)
	}
	
	func didChangeCurrentWorkingDirectory(_ workingDirectory: URL) {

	}
	
	private func processCommand(_ command: String) {
		
		// Trim leading/trailing space
		let command = command.trimmingCharacters(in: .whitespacesAndNewlines)
		
		// Dispatch the command to the executor
		terminalView.executor.dispatch(command)
	}
	
}


class CallbackCommandExecutor: CommandExecutorDelegate, ParserDelegate {
	
	let callback: (() -> Void)
	
	let terminalView: TerminalView
	
	init(commandStr: String, terminalView: TerminalView, callback: @escaping (() -> Void)) {
		
		self.callback = callback
		self.terminalView = terminalView
		
		terminalView.stderrParser.delegate = self
		terminalView.stdoutParser.delegate = self
		
		terminalView.executor.delegate = self
		
		terminalView.executor.dispatch(commandStr)
	}
	
	func commandExecutor(_ commandExecutor: CommandExecutor, receivedStdout stdout: Data) {
		terminalView.stdoutParser.parse(stdout)
	}
	
	func commandExecutor(_ commandExecutor: CommandExecutor, receivedStderr stderr: Data) {
		terminalView.stderrParser.parse(stderr)
	}
	
	func commandExecutor(_ commandExecutor: CommandExecutor, didChangeWorkingDirectory to: URL) {
		
	}
	
	func commandExecutor(_ commandExecutor: CommandExecutor, stateDidChange newState: CommandExecutor.State) {
		
	}
	
	func parser(_ parser: Parser, didReceiveString string: NSAttributedString) {
		
		terminalView.performOnMain {
			self.terminalView.appendText(string)
		}
		
	}
	
	func parserDidEndTransmission(_ parser: Parser) {
		
		terminalView.performOnMain {
			
			self.terminalView.stderrParser.delegate = self.terminalView
			self.terminalView.stdoutParser.delegate = self.terminalView
			
			self.terminalView.executor.delegate = self.terminalView
			
			self.callback()
			
		}
		
	}
	
}
