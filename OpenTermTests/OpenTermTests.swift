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
	
	let terminalView = TerminalView()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		
		initializeEnvironment()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
		
		terminalView.clearScreen()

    }
	
	/// Test to make sure commands don't accidentally get added or removed.
	func testAvailableCommands() {
		
		let terminalVC = TerminalViewController()
		
		let commands = terminalVC.availableCommands()
		
		let expectedCommands = ["awk", "cat", "cd", "chflags", "chksum", "clear", "compress", "cp", "curl", "date", "dig", "du", "echo", "egrep", "env", "fgrep", "grep", "gunzip", "gzip", "help", "host", "link", "ln", "ls", "mkdir", "mv", "nc", "nslookup", "open-url", "pbcopy", "pbpaste", "ping", "printenv", "pwd", "readlink", "rlogin", "rm", "rmdir", "scp", "sed", "setenv", "sftp", "share", "ssh", "ssh-keygen", "stat", "sum", "tar", "tee", "telnet", "touch", "tr", "uname", "uncompress", "unlink", "unsetenv", "uptime", "wc", "whoami"]
		
		XCTAssertEqual(commands, expectedCommands)
		
	}
    
    func testCURL() {
		
		let delegator = TerminalViewDelegator(terminalView: terminalView)
		
		terminalView.delegate = delegator
		
		delegator.didEnterCommand("curl")
		
		let deviceName = terminalView.deviceName
		
		let delayExpectation = expectation(description: "Waiting for command")

		let expectedOutput = "\(deviceName): curl: try \'curl --help\' or \'curl --manual\' for more information\n\(deviceName): "
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			
			let output = self.terminalView.textView.text
			
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
