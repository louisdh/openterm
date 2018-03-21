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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCURL() {
		
		let terminalView = TerminalView()
		
		initializeEnvironment()

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
