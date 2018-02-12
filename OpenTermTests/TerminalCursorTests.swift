//
//  TerminalCursorTests.swift
//  OpenTermTests
//
//  Created by Ian McDowell on 2/10/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import XCTest
@testable import OpenTerm

class TerminalCursorTests: XCTestCase {

	var storage: NSTextStorage!
	var cursor: TerminalCursor!

	override func setUp() {
		super.setUp()

		cursor = TerminalCursor.zero
		storage = NSTextStorage.init(string: "")
	}

	override func tearDown() {
		super.tearDown()

	}

	// TODO: Test move up
	// TODO: Test set y axis

	func testAppendMoveRightThenLeftByLength() {
		let str = "hello"
		storage.append(NSAttributedString.init(string: str))

		for _ in 0..<str.count {
			cursor.move(.right, in: storage)
		}

		XCTAssertEqual(cursor.x, str.count, "Cursor moved the number of times requested")
		XCTAssertEqual(cursor.y, 0, "Cursor didn't move vertically")
		XCTAssertEqual(cursor.offset, str.count, "Offset == end of string")

		for _ in 0..<str.count {
			cursor.move(.left, in: storage)
		}

		XCTAssertEqual(cursor.x, 0, "Cursor moved back to beginning")
		XCTAssertEqual(cursor.y, 0, "Cursor didn't move vertically")
		XCTAssertEqual(cursor.offset, 0, "Offset == beginning of string")
	}

	func testMoveLeftFromZero() {

		let x = cursor.x
		let offset = cursor.offset
		cursor.move(.left, in: storage)

		XCTAssertEqual(cursor.x, x, "Cursor didn't move")
		XCTAssertEqual(cursor.offset, offset, "Cursor didn't move")
	}

	func testMoveDownALine() {

		let line1 = "hello"
		let line2 = "world"

		storage.append(NSAttributedString.init(string: line1))
		// Move to end of line1
		for _ in 0..<line1.count {
			cursor.move(.right, in: storage)
		}

		XCTAssertEqual(cursor.x, line1.count, "Cursor should be at the end of the first line")
		XCTAssertEqual(cursor.y, 0, "Cursor should be on the first line")

		storage.append(NSAttributedString.init(string: "\n" + line2))
		cursor.move(.down, in: storage)
		XCTAssertEqual(cursor.x, line1.count, "Cursor didn't move horizontally")
		XCTAssertEqual(cursor.y, 1, "Cursor moved down a row")
	}

	func testMoveEndOfString() {
		let string = "hello\nworld\ntest\nstring\n"

		storage.append(NSAttributedString.init(string: string))
		cursor.move(.endOfString, in: storage)

		XCTAssertEqual(cursor.x, 0, "Cursor x should be 0 since last character is newline")
		XCTAssertEqual(cursor.y, 4, "Cursor y should be 4 since there are 4 lines")
		XCTAssertEqual(cursor.offset, string.count, "Offset should be end of string")
	}

	func testMoveOutOfEmptyString() {
		cursor.move(.right, in: storage)
		XCTAssert(cursor.x == 0 && cursor.y == 0, "Cursor should not move if out of bounds")
		cursor.move(.left, in: storage)
		XCTAssert(cursor.x == 0 && cursor.y == 0, "Cursor should not move if out of bounds")
//		cursor.move(.up, in: storage)
//		XCTAssert(cursor.y == 0, "Cursor should not move if out of bounds")
		cursor.move(.down, in: storage)
		XCTAssert(cursor.y == 0 && cursor.y == 0, "Cursor should not move if out of bounds")
	}

	func testSetXAxis() {
		let string = "hello\nworld\ntest\nstring"

		storage.append(NSAttributedString.init(string: string))
		cursor.move(.right, in: storage)
		cursor.move(.right, in: storage)

		cursor.move(.down, in: storage)

		XCTAssertEqual(cursor.x, 2, "Cursor should have moved right 2")
		XCTAssertEqual(cursor.y, 1, "Cursor should have moved down 1")

		let offset = cursor.offset
		cursor.set(.x, to: 5, in: storage)

		XCTAssertEqual(cursor.x, 5, "Cursor should have moved to position that we told it to")
		XCTAssertEqual(cursor.y, 1, "Cursor should not have moved vertically")
		XCTAssertEqual(cursor.offset, offset + 3, "Cursor should have moved right 3")
	}
	func testSetXAxisOutOfBounds() {
		let string = "hello\nworld"

		storage.append(NSAttributedString.init(string: string))

		cursor.set(.x, to: 5, in: storage)

		XCTAssertEqual(cursor.x, 5, "Cursor should move properly in bounds")

		cursor.set(.x, to: 500, in: storage)

		XCTAssertEqual(cursor.x, 5, "Cursor should not move if given out of bounds value")
	}

	func testDistanceToEndOfLineSingle() {
		let string = "really long single line string"
		storage.append(NSAttributedString.init(string: string))

		let distance = cursor.distanceToEndOfLine(in: storage)

		XCTAssertEqual(distance, string.count, "Distance to end of line should be the length of the string")
	}

	func testDistanceToEndOfLineMultipleLines() {
		let line1 = "really long"
		let line2 = "multiple line string"
		storage.append(NSAttributedString.init(string: line1 + "\n" + line2))

		let distance = cursor.distanceToEndOfLine(in: storage)

		XCTAssertEqual(distance, line1.count, "Distance to end of line should be the length of the first line")
	}
}
