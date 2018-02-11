//
//  Parser.swift
//  OpenTerm
//
//  Created by Ian McDowell on 1/31/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

/// Protocol to receive notifications when the parser finds interesting things in the data that it's processing.
protocol ParserDelegate: class {

	/// When an attributed string is found, it is passed into this method.
	/// The attributes will be determined based on the current ANSI text state.
	/// This string will not contain control characters, newlines, carriage returns, etc.
	func parser(_ parser: Parser, didReceiveString string: NSAttributedString)

	/// A carriage return was found. The cursor position should be updated.
	func parserDidReceiveCarriageReturn(_ parser: Parser)

	/// A newline character was found. The cursor position should be updated.
	func parserDidReceiveNewLine(_ parser: Parser)

	/// A backspace character was found. The cursor position should be updated.
	func parserDidReceiveBackspace(_ parser: Parser)

	/// The cursor was moved in the given direction, `count` number of times.
	func parser(_ parser: Parser, didMoveCursorInDirection direction: TerminalCursor.Direction, count: Int)

	/// The cursor was moved to a given position (0..<width) on the given x/y axis
	func parser(_ parser: Parser, didMoveCursorTo position: Int, onAxis axis: TerminalCursor.Axis)

	/// An end of text character was received
	func parserDidEndTransmission(_ parser: Parser)
}

/// The parser transforms data received from stdout/stderr into NSAttributedStrings.
/// It reads the data by character and performs actions based on control codes, including applying colors.
/// For more information about escape codes, see https://en.wikipedia.org/wiki/ANSI_escape_code
class Parser {
	/// List of constants that are needed for parsing.
	enum Code: String {
		case escape = "\u{1B}"
		// The "End of transmission" control code. Is used to indicate end-of-file on the terminal.
		case endOfTransmission = "\u{04}"

		// CR (CTRL+M), \r move to the beginning of the line
		case carriageReturn = "\u{0D}"

		// LF (CTRL+J), \n new line
		case newLine = "\u{0A}"

		// BS (CTRL+H), Move the cursor one position leftwards
		case backspace = "\u{08}"

		// Shift into another character set
		case shiftIn = "\u{0E}"

		// Shift back to the regular character set
		case shiftOut = "\u{0F}"

		var character: Character { return Character(rawValue) }

		/// The following are recognized escape sequences, but there are more that we don't (current) recognize.
		/// They should come directly after the `escape` code.
		enum EscapeCode: String {
			case controlSequenceIntroducer = "["

			var character: Character { return Character(rawValue) }
		}

		/// A "CSI" sequence is `ESC[` + colon-separated parameters + a suffix.
		/// These are the suffix possibilities.
		enum ControlSequenceSuffix: String {
			case cursorUp = "A"
			case cursorDown = "B"
			case cursorForward = "C"
			case cursorBack = "D"
			case cursorNextLine = "E"
			case cursorPreviousLine = "F"
			case cursorHorizontalAbsolute = "G"
			case cursorPosition = "H"
			case eraseInDisplay = "J"
			case eraseInLine = "K"
			case scrollUp = "S"
			case scrollDown = "T"
			case horizontalVerticalPosition = "f" // same as cursorPosition
			case selectGraphicRendition = "m" // fonts & colors
			case auxPortControl = "i"
			case deviceStatusReport = "n"
			case saveCursorPosition = "s"
			case restoreCursorPosition = "u"
		}
	}
	/// The state of the parser. As the `handle` method is called, this state will change.
	private enum State {
		case normal
		case escape
		case csiSequence(parameters: String)
	}

	weak var delegate: ParserDelegate?
	private var textState: ANSITextState = ANSITextState()
	private var state: State = .normal
	private var dataBuffer = Data()

	func parse(_ data: Data) {
		let didEnd = self.decodeUTF8(fromData: data, buffer: &dataBuffer)
		if didEnd {
			self.delegate?.parserDidEndTransmission(self)
		}
	}

	func reset() {
		textState.reset()
		state = .normal
		dataBuffer = Data()
	}

	private func decodeUTF8(fromData data: Data, buffer: inout Data) -> Bool {
		let data = buffer + data

		// Parse what we can from the previous leftover and the new data.
		let (leftover, didEnd) = self.decodeUTF8(fromData: data)

		// There are two reasons we could get leftover data:
		// - An invalid character was found in the middle of the string
		// - An invalid character was found at the end
		//
		// We only want to keep data for parsing in the second case, since
		// the parsing most likely failed due to missing data that will come
		// in the next read from the pipe.
		// The max size for the stuff we care about is the width of a utf8 code unit.
		if leftover.count <= UTF8.CodeUnit.bitWidth {
			buffer = leftover
		} else {
			buffer = Data()
		}

		return didEnd
	}

	/// Decode UTF-8 string from the given data.
	/// This is a custom implementation that decodes what characters it can then returns whatever it can't,
	/// which is necessary since data can come in arbitrarily-sized chunks of bytes, with characters split
	/// across multiple chunks.
	/// The first time decoding fails, all of the rest of the data will be returned.
	private func decodeUTF8(fromData data: Data) -> (remaining: Data, didEnd: Bool) {
		let byteArray = [UInt8](data)

		var utf8Decoder = UTF8()
		var byteIterator = byteArray.makeIterator()
		var decodedByteCount = 0
		var didEnd: Bool = false
		Decode: while !didEnd {
			switch utf8Decoder.decode(&byteIterator) {
			case .scalarValue(let v):
				didEnd = self.handle(Character(v))
				decodedByteCount += UTF8.encode(v)!.count
			case .emptyInput, .error:
				break Decode
			}
		}

		let remaining = Data.init(bytes: byteArray.suffix(from: decodedByteCount))
		return (remaining, didEnd)
	}

	/// This method is called for each UTF-8 character that is received.
	/// It should perform state changes based on that character, then
	/// return an attributed string that renders the character
	private func handle(_ character: Character) -> Bool {
		// Create a string with the given character
		let str = String.init(character)

		// Try to parse a code
		switch self.state {
		case .normal:
			guard let code = Code.init(rawValue: str) else {
				// While in normal mode, unless we found a code, we should return a string using the current
				// textState's attributes.
				self.delegate?.parser(self, didReceiveString: NSAttributedString.init(string: str, attributes: textState.attributes))
				return false
			}
			switch code {
			case .endOfTransmission:
				// Ended transmission, return immediately.
				return true
			case .escape:
				self.state = .escape
			case .carriageReturn:
				self.delegate?.parserDidReceiveCarriageReturn(self)
			case .newLine:
				self.delegate?.parserDidReceiveNewLine(self)
			case .backspace:
				self.delegate?.parserDidReceiveBackspace(self)
			case .shiftIn:
				// TODO: Support different character encodings
				break
			case .shiftOut:
				// TODO: Support different character encodings
				break
			}
		case .escape:
			if let escapeCode = Code.EscapeCode.init(rawValue: str) {
				switch escapeCode {
				case .controlSequenceIntroducer:
					// We found a CSI sequence.
					self.state = .csiSequence(parameters: "")
				}
			} else {
				// Last character was escape, but we didn't find a recognizable code. Return to normal.
				self.state = .normal
			}
		case .csiSequence(let parameters):
			// We are in the middle of parsing a csi sequence

			// The following ranges are from: https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_sequences

			// ASCII 0–9:;<=>?
			let parameterRange: CountableClosedRange<UInt32> = 0x30...0x3F

			// ASCII space and !"#$%&'()*+,-./
			let intermediateBytesRange: CountableClosedRange<UInt32> = 0x20...0x2F

			// ASCII @A–Z[\]^_`a–z{|}~
			let finalByteRange: CountableClosedRange<UInt32> = 0x40...0x7E

			// Get scalar value from character, then find which range it fits in
			let scalar = character.unicodeScalars.first!.value
			if parameterRange.contains(scalar) || intermediateBytesRange.contains(scalar) {
				self.state = .csiSequence(parameters: parameters + str)
			} else if finalByteRange.contains(scalar) {
				if let suffix = Code.ControlSequenceSuffix.init(rawValue: str) {

					// Most parameters are a single number, and if missing, default to 1.
					// so for convenience, parse that now.
					let intValue = Int(parameters) ?? 1

					switch suffix {
					case .selectGraphicRendition:
						// Put the parameters into the text state, which updates its attributes.
						textState.parse(escapeCodes: parameters)
					case .cursorUp:
						self.delegate?.parser(self, didMoveCursorInDirection: .up, count: intValue)
					case .cursorDown:
						self.delegate?.parser(self, didMoveCursorInDirection: .down, count: intValue)
					case .cursorForward:
						self.delegate?.parser(self, didMoveCursorInDirection: .right, count: intValue)
					case .cursorBack:
						self.delegate?.parser(self, didMoveCursorInDirection: .left, count: intValue)
					case .cursorNextLine:
						// Moves cursor to beginning of the line n (default 1) lines down
						// Combine the beginning of line and down directions to achieve this
						self.delegate?.parser(self, didMoveCursorInDirection: .beginningOfLine, count: 1)
						self.delegate?.parser(self, didMoveCursorInDirection: .down, count: intValue)
					case .cursorPreviousLine:
						// Moves cursor to beginning of the line n (default 1) lines up
						// Combine the beginning of line and up directions to achieve this
						self.delegate?.parser(self, didMoveCursorInDirection: .beginningOfLine, count: 1)
						self.delegate?.parser(self, didMoveCursorInDirection: .up, count: intValue)
					case .cursorHorizontalAbsolute:
						// Cursor should move to the intValue'th column.
						// Delegate value is 0-based, and this is 1-based, so subtract 1.
						self.delegate?.parser(self, didMoveCursorTo: intValue - 1, onAxis: .x)
					case .cursorPosition, .horizontalVerticalPosition:
						// TODO: Set x,y cursor position (1-based)
						break
					case .eraseInDisplay:
						// TODO: Clear part of the screen
						break
					case .eraseInLine:
						// TODO: Erase part of line without changing cursor position
						break
					case .scrollUp:
						// TODO: Scroll up
						break
					case .scrollDown:
						// TODO: Scroll down
						break
					case .auxPortControl:
						// Not supported
						break
					case .deviceStatusReport:
						// TODO: Send x,y cursor position to application
						break
					case .saveCursorPosition:
						// TODO: Save cursor
						break
					case .restoreCursorPosition:
						// TODO: Restore cursor
						break
					}
				}
				// The CSI sequence is done, so return to normal state.
				self.state = .normal
			} else {
				// Character was not in any acceptable range, so ignore it and exit csi state
				self.state = .normal
			}
		}

		// If we made it here, that means that we're in the middle of handling states.
		// No characters are output during this time.
		return false
	}
}

extension String {

	#if DEBUG
	static var colorTestingString: String {
		var s = ""

		// Write intro using default colors
		s += "\u{001B}[39;49mThis is a test of the colors in OpenTerm.\u{001B}[0m" + "\n\n"

		let ranges: [(name: String, range: CountableClosedRange<Int>)] = [
			("Standard colors", (30...37)),
			("Standard backgrounds", (40...47)),
			("Bright colors", (90...97)),
			("Bright backgrounds", (100...107))
		]

		for range in ranges {
			s += range.name + ":\n" + range.range.map { "\u{001B}[\($0)m\($0)\u{001B}[0m" }.joined(separator: " ") + "\n\n"
		}

		// 8-bit (0-255)
		s += "8-bit foregrounds:\n\t" + (0...255).map { "\u{0001B}[38;5;\($0)m\($0)\u{001B}[0m" }.joined(separator: "\t") + "\n\n"
		s += "8-bit backgrounds:\n\t" + (0...255).map { "\u{0001B}[48;5;\($0)m\($0)\u{001B}[0m" }.joined(separator: "\t") + "\n\n"
		return s
	}
	#endif
}
