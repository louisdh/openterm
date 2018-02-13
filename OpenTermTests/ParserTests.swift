//
//  ParserTests.swift
//  OpenTermTests
//
//  Created by Ian McDowell on 2/11/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import XCTest
@testable import OpenTerm

class ParserTests: XCTestCase {

	var parser: Parser!
	var parserDelegate: TestParserDelegate!
	override func setUp() {
		super.setUp()

		parser = Parser()
		parserDelegate = TestParserDelegate()
		parser.delegate = parserDelegate
	}

	override func tearDown() {
		super.tearDown()
		
	}

	// Implementation of the ParserDelegate that stores received messages in-order.
	class TestParserDelegate: ParserDelegate {

		enum ParserDelegateMessage {
			case string(string: NSAttributedString)
			case carriageReturn
			case newLine
			case backspace
			case cursorMove(direction: TerminalCursor.Direction)
			case cursorSet(position: Int, axis: TerminalCursor.Axis)
			case endTransmission
		}

		var receivedMethods: [ParserDelegateMessage] = []

		func parser(_ parser: Parser, didReceiveString string: NSAttributedString) {
			receivedMethods.append(.string(string: string))
		}
		func parserDidReceiveCarriageReturn(_ parser: Parser) {
			receivedMethods.append(.carriageReturn)
		}
		func parserDidReceiveNewLine(_ parser: Parser) {
			receivedMethods.append(.newLine)
		}
		func parserDidReceiveBackspace(_ parser: Parser) {
			receivedMethods.append(.backspace)
		}
		func parser(_ parser: Parser, didMoveCursorInDirection direction: TerminalCursor.Direction) {
			receivedMethods.append(.cursorMove(direction: direction))
		}
		func parser(_ parser: Parser, didMoveCursorTo position: Int, onAxis axis: TerminalCursor.Axis) {
			receivedMethods.append(.cursorSet(position: position, axis: axis))
		}
		func parserDidEndTransmission(_ parser: Parser) {
			receivedMethods.append(.endTransmission)
		}
	}

	private func send(_ text: String) {
		parser.parse(text.data(using: .utf8)!)
	}

	func testBasicText() {
		let str = "hello world"

		send(str)

		// Each character should be received in a message
		var receivedStr = ""
		for method in parserDelegate.receivedMethods {
			switch method {
			case .string(let str):
				receivedStr += str.string
			default:
				XCTFail("Unexpected method called on parser delegate")
			}
		}

		XCTAssertEqual(str, receivedStr, "Received string should equal sent string")
	}

	func testTextWithNewLine() {
		let str = "hello\nworld"

		send(str)

		var receivedStr = ""
		for method in parserDelegate.receivedMethods {
			switch method {
			case .string(let str):
				receivedStr += str.string
			case .newLine:
				receivedStr += "\n"
			default:
				XCTFail("Unexpected method called on parser delegate")
			}
		}

		XCTAssertEqual(str, receivedStr, "Received string should equal sent string")
	}
}
