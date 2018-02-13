//
//  TerminalBuffer.swift
//  OpenTerm
//
//  Created by Ian McDowell on 2/9/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

protocol TerminalBufferDelegate: class {

	/// When the cursor moves, this method will be called.
	func terminalBuffer(_ buffer: TerminalBuffer, cursorDidChange cursor: TerminalCursor)

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
	private let stdinParser: Parser

	private var cursor: TerminalCursor {
		didSet {
			delegate?.terminalBuffer(self, cursorDidChange: cursor)
		}
	}

	init() {
		storage = NSTextStorage()
		layoutManager = NSLayoutManager()
		textContainer = NSTextContainer()

		stdoutParser = Parser()
		stderrParser = Parser()
		stdinParser = Parser()

		cursor = .zero

		storage.addLayoutManager(layoutManager)
		layoutManager.addTextContainer(textContainer)

		stdoutParser.delegate = self
		stderrParser.delegate = self
		stdinParser.delegate = self
	}

	/// Reset the state of the parsers & the cursor position
	func reset() {
		stdoutParser.reset()
		stderrParser.reset()
		stdinParser.reset()
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

	/// Add raw data from stdin
	func add(stdin: Data) {
		stdinParser.parse(stdin)
	}

	/// Insert the given attributed string into the storage after the current cursor position.
	/// Characters after the cursor position that are in the way are replaced by the contents of the string.
	/// The attributed string is expected to not contain control characters or newlines.
	/// The cursor is moved to the end of the added text.
	private func insert(_ attributedString: NSAttributedString) {
		// Get cursor position as distance from start
		let insertionPoint = cursor.offset
		let insertionLength = attributedString.string.utf16.count
		assert(insertionPoint <= storage.length, "Insertion point must be within the storage's size")

		// Get the distance from the cursor to the end of the string
		let distanceToEnd = cursor.distanceToEndOfLine(in: storage)

		// Create an NSRange for replacing characters.
		// It starts at the insertion point, and has length of whichever one is smaller:
		// - The length of the inserted string
		// - The distance from the insertion point to the end
		let range = NSRange.init(location: insertionPoint, length: min(distanceToEnd, insertionLength))

		self.storage.replaceCharacters(in: range, with: attributedString)

		// Move cursor right by the number of characters in the inserted string
		self.cursor.move(.right(distance: insertionLength), in: self.storage)
	}
}

extension TerminalBuffer: ParserDelegate {
	// The methods below are performOnMain because:
	// Parser delegates are called on the Parser's thread
	// TerminalBufferTests call these methods from the main thread, and expect them to happen synchronously.

	func parser(_ parser: Parser, didReceiveString string: NSAttributedString) {
		DispatchQueue.performOnMain {
			self.insert(string)
		}
	}
	func parserDidReceiveCarriageReturn(_ parser: Parser) {
		DispatchQueue.performOnMain {
			self.cursor.move(.beginningOfLine, in: self.storage)
		}
	}
	func parserDidReceiveNewLine(_ parser: Parser) {
		DispatchQueue.performOnMain {
			self.storage.append(NSAttributedString.init(string: "\n"))
			self.cursor.move(.beginningOfLine, in: self.storage)
			self.cursor.move(.down(distance: 1), in: self.storage)
		}
	}
	func parserDidReceiveBackspace(_ parser: Parser) {
		DispatchQueue.performOnMain {
			// TODO: Is this correct? Should we also modify storage at all?
			self.cursor.move(.left(distance: 1), in: self.storage)
		}
	}
	func parser(_ parser: Parser, didMoveCursorInDirection direction: TerminalCursor.Direction) {
		DispatchQueue.performOnMain {
			self.cursor.move(direction, in: self.storage)
		}
	}
	func parser(_ parser: Parser, didMoveCursorTo position: Int, onAxis axis: TerminalCursor.Axis) {
		DispatchQueue.performOnMain {
			self.cursor.set(axis, to: position, in: self.storage)
		}
	}
	func parserDidEndTransmission(_ parser: Parser) {
		DispatchQueue.performOnMain {
			self.delegate?.terminalBufferDidReceiveETX()
		}
	}
}

extension TerminalBuffer: CustomDebugStringConvertible {

	var debugDescription: String {
		let lines = storage.string.components(separatedBy: .newlines)
		let currentLine = lines[cursor.y]
		return "length: \(storage.string.count), lines: \(lines.count), cursor: \(cursor.debugDescription), current line: \(currentLine)"
	}
}
