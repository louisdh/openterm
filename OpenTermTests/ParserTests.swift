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

		parser = Parser(type: .stdout)
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

	private func end() {
		// Must send end of transmission when we are done, since that will flush the pending text out of the parser
		parser.parse(Parser.Code.endOfTransmission.rawValue.data(using: .utf8)!)
	}

	private func receivedString(withControlCharacters controlCharacters: Bool = true) -> NSAttributedString {
		let receivedStr = NSMutableAttributedString()
		for method in parserDelegate.receivedMethods {
			switch method {
			case .string(let str):
				receivedStr.append(str)
			case .newLine:
				if controlCharacters {
					receivedStr.append(NSAttributedString.init(string: "\n"))
				}
			case .carriageReturn:
				if controlCharacters {
					receivedStr.append(NSAttributedString.init(string: "\r"))
				}
			case .endTransmission:
				break
			default:
				XCTFail("Unexpected method called on parser delegate")
			}
		}
		return receivedStr
	}

	func testBasicText() {
		let str = "hello world"

		send(str)
		end()

		XCTAssertEqual(str, receivedString().string, "Received string should equal sent string")
	}

	func testTextWithNewLine() {
		let str = "hello\nworld"

		send(str)
		end()

		XCTAssertEqual(str, receivedString().string, "Received string should equal sent string")
	}

	func testSanitizedOutput() {
		let str = DocumentManager.shared.activeDocumentsFolderURL.path

		send(str)
		end()

		XCTAssertEqual(receivedString().string, "~")
	}

	func testLSColors() {
		let esc = Parser.Code.escape.rawValue
		// First line = normal output
		let line1 = "cacert.pem\tctd.cpp\techoTest\tinput\tknown_hosts"
		// Second line = bold / blue "lua"
		let line2text = "lua"
		let line2 = "\(esc)[1m\(esc)[34m\(line2text)\(esc)[39;49m\(esc)[0m"
		// Third line = normal "path"
		let line3 = "path"
		// Fourth line = bold / green "test"
		let line4text = "test"
		let line4 = "\(esc)[1m\(esc)[32m\(line4text)\(esc)[39;49m\(esc)[0m"
		// Fifth line = normal "test.tar.gz"
		let line5 = "test.tar.gz"
		// Sixth line = bold / purple "test2"
		let line6text = "test2"
		let line6 = "\(esc)[1m\(esc)[35m\(line6text)\(esc)[39;49m\(esc)[0m"

		send([line1, line2, line3, line4, line5, line6].joined(separator: "\n"))
		end()

		let received = self.receivedString(withControlCharacters: false)

		// Retrieve an attributed substring for each line
		var currentPosition = 0
		let rLine1 = received.attributedSubstring(from: NSRange.init(location: currentPosition, length: line1.count))
		currentPosition += rLine1.length
		let rLine2 = received.attributedSubstring(from: NSRange.init(location: currentPosition, length: line2text.count))
		currentPosition += rLine2.length
		let rLine3 = received.attributedSubstring(from: NSRange.init(location: currentPosition, length: line3.count))
		currentPosition += rLine3.length
		let rLine4 = received.attributedSubstring(from: NSRange.init(location: currentPosition, length: line4text.count))
		currentPosition += rLine4.length
		let rLine5 = received.attributedSubstring(from: NSRange.init(location: currentPosition, length: line5.count))
		currentPosition += rLine5.length
		let rLine6 = received.attributedSubstring(from: NSRange.init(location: currentPosition, length: line6text.count))
		currentPosition += rLine6.length

		// Make sure we got through the whole string
		XCTAssertEqual(currentPosition, received.length)

		// Make sure lines are equal to what we passed in
		XCTAssertEqual(rLine1.string, line1)
		XCTAssertEqual(rLine2.string, line2text)
		XCTAssertEqual(rLine3.string, line3)
		XCTAssertEqual(rLine4.string, line4text)
		XCTAssertEqual(rLine5.string, line5)
		XCTAssertEqual(rLine6.string, line6text)

		// For lines with styles, make sure styles were applied
		// TODO
	}
	
}
