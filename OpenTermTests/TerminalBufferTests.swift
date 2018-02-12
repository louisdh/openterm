//
//  TerminalBufferTests.swift
//  OpenTermTests
//
//  Created by Ian McDowell on 2/10/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import XCTest
@testable import OpenTerm

// These tests call the ParserDelegate methods, and intend to avoid sending data to the parser if at all possible.
// Save tests for the Parser for the Parser's test cases.
class TerminalBufferTests: XCTestCase {

	var buffer: TerminalBuffer!

	// Passing delegate methods from a parser require a Parser parameter. Pass an empty one in to get it to compile.
	// If the TerminalBuffer ever reads stuff about the parser (it currently does not), this will need a better implementation
	// Such as to make the TerminalBuffer's parser non-private
	let dummyParser = Parser()

	override func setUp() {
		super.setUp()

		buffer = TerminalBuffer()
	}

	override func tearDown() {
		super.tearDown()

	}

	// MARK: Helper methods

	// Since the buffer doesn't expose its NSTextStorage, we must retrieve it from its public NSTextContainer
	private var bufferContents: String {
		return buffer.textContainer.layoutManager!.textStorage!.string
	}

	// Helper method to send a string to the buffer
	private func receiveString(_ string: String) {
		buffer.parser(dummyParser, didReceiveString: NSAttributedString.init(string: string))
	}
	private func newLine() {
		buffer.parserDidReceiveNewLine(dummyParser)
	}
	private func carriageReturn() {
		buffer.parserDidReceiveCarriageReturn(dummyParser)
	}

	// MARK: Tests

	func testReceiveString() {
		let string = "hello world"

		receiveString(string)

		XCTAssertEqual(bufferContents, string, "Buffer should equal the received string")
	}

	func testStringsWithNewLine() {
		let line1 = "hello world"
		let line2 = "test"

		receiveString(line1)
		newLine()
		receiveString(line2)

		XCTAssertEqual(bufferContents, line1 + "\n" + line2, "Buffer should equal the text sent in order")
	}

	func testStringsWithCarriageReturn() {
		let line1pt1 = "replaceme"
		let line1pt2 = " test"
		let line2 = "123456789"

		receiveString(line1pt1 + line1pt2)
		carriageReturn()
		receiveString(line2)

		XCTAssertEqual(bufferContents, line2 + line1pt2, "Buffer should equal the second line + leftover first line")
	}

}
