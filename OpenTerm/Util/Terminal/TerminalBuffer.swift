//
//  TerminalBuffer.swift
//  OpenTerm
//
//  Created by Ian McDowell on 2/9/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

protocol TerminalBufferDelegate: class {

	/// An End of Text message was received, which means the current command finished.
	func terminalBufferDidReceiveETX()
}

/// The terminal buffer is the entity that passes command output to a UITextView.
/// Here is where escape codes are handled, and data is stored.
///
/// A buffer manages contains the following important things:
/// - Storage => NSTextStorage (NSMutableAttributedString subclass), that contains all text in the terminal
/// - Parsers => Parser objects that convert Data to NSAttributedString
/// - Cursor => A cursor pointing to a location in the storage. As new data comes in, it is appended at the cursor position.
///
/// The buffer exposes an NSTextContainer, which a UITextView should add to display terminal contents.
/// Most changes will flow from NSTextStorage -> NSLayoutManager -> NSTextContainer -> UITextView automatically.
/// Additional notifications about changes will be sent to the `delegate` of the terminal buffer.
class TerminalBuffer {

	weak var delegate: TerminalBufferDelegate?

	private let storage: NSTextStorage
	private let layoutManager: NSLayoutManager
	let textContainer: NSTextContainer

	private let stdoutParser: Parser
	private let stderrParser: Parser

	private var cursor: TerminalCursor

	init() {
		storage = NSTextStorage()
		layoutManager = NSLayoutManager()
		textContainer = NSTextContainer()

		stdoutParser = Parser()
		stderrParser = Parser()

		cursor = .zero

		storage.addLayoutManager(layoutManager)
		layoutManager.addTextContainer(textContainer)

		stdoutParser.delegate = self
		stderrParser.delegate = self
	}

	/// Reset the state of the parsers & the cursor position
	func reset() {
		stdoutParser.reset()
		stderrParser.reset()
		cursor = .zero
	}

	/// Move the cursor to the end of the storage
	func moveCursorToEnd() {
		cursor.move(.endOfString, in: storage)
	}

	/// Add raw data from stdout
	func add(stdout: Data) {
		stdoutParser.parse(stdout)
	}

	/// Add raw data from stderr
	func add(stderr: Data) {
		stderrParser.parse(stderr)
	}

	/// Insert the given attributed string into the storage after the current cursor position.
	/// Characters after the cursor position that are in the way are replaced by the contents of the string.
	/// The attributed string is expected to not contain control characters or newlines.
	/// The cursor is moved to the end of the added text.
	private func insert(_ attributedString: NSAttributedString) {
		// Get cursor position as distance from start
		let insertionPoint = cursor.offset
		assert(insertionPoint <= storage.length, "Insertion point must be within the storage's size")

		// Get the distance from the cursor to the end of the string
		let distanceToEnd = cursor.distanceToEndOfLine(in: storage)

		// Create an NSRange for replacing characters.
		// It starts at the insertion point, and has length of whichever one is smaller:
		// - The length of the inserted string
		// - The distance from the insertion point to the end
		let range = NSRange.init(location: insertionPoint, length: min(distanceToEnd, attributedString.length))

		self.storage.replaceCharacters(in: range, with: attributedString)

		// Move cursor right by the number of characters in the inserted string
		for _ in 0..<attributedString.string.count {
			self.cursor.move(.right, in: self.storage)
		}
	}
}

extension TerminalBuffer: ParserDelegate {
	func parser(_ parser: Parser, didReceiveString string: NSAttributedString) {
		DispatchQueue.main.async {
			self.insert(string)
		}
	}
	func parserDidReceiveCarriageReturn(_ parser: Parser) {
		DispatchQueue.main.async {
			self.cursor.move(.beginningOfLine, in: self.storage)
		}
	}
	func parserDidReceiveNewLine(_ parser: Parser) {
		DispatchQueue.main.async {
			self.storage.append(NSAttributedString.init(string: "\n"))
			self.cursor.move(.down, in: self.storage)
			self.cursor.move(.beginningOfLine, in: self.storage)
		}
	}
	func parserDidReceiveBackspace(_ parser: Parser) {
		DispatchQueue.main.async {
			// TODO: Is this correct? Should we also modify storage at all?
			self.cursor.move(.left, in: self.storage)
		}
	}
	func parser(_ parser: Parser, didMoveCursorInDirection direction: TerminalCursor.Direction, count: Int) {
		DispatchQueue.main.async {
			for _ in 0..<count {
				self.cursor.move(direction, in: self.storage)
			}
		}
	}
	func parser(_ parser: Parser, didMoveCursorTo position: Int, onAxis axis: TerminalCursor.Axis) {
		DispatchQueue.main.async {
			self.cursor.set(axis, to: position, in: self.storage)
		}
	}
	func parserDidEndTransmission(_ parser: Parser) {
		delegate?.terminalBufferDidReceiveETX()
	}
}
