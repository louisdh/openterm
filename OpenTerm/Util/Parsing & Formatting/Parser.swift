//
//  Parser.swift
//  OpenTerm
//
//  Created by Ian McDowell on 1/31/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

protocol ParserDelegate: class {
	func parser(_ parser: Parser, didReceiveString string: NSAttributedString)
	func parserDidEndTransmission(_ parser: Parser)
}

/// The parser transforms data received from stdout/stderr into NSAttributedStrings.
/// It reads the data by character and performs actions based on control codes, including applying colors.
/// For more information about escape codes, see https://en.wikipedia.org/wiki/ANSI_escape_code
class Parser {
	/// List of constants that are needed for parsing.
	enum Code: String {
		case escape = "\u{001B}"

		// The "End of text" control code. This is the equivalent of pressing CTRL+C
		case endOfText = "\u{0003}"

		// The "End of transmission" control code. This is the equivalent of pressing CTRL+D
		// When received by stdout pipe, the didFinishDispatchWithExitCode delegate method is called.
		case endOfTransmission = "\u{0004}"

		var character: Character { return Character(rawValue) }

		/// The following are recognized escape sequences.
		/// They should come directly after the `escape` code.
		enum EscapeCode: String {
			case singleShiftTwo = "N"
			case singleShiftThree = "O"
			case deviceControlString = "P"
			case controlSequenceIntroducer = "["
			case stringTerminator = "\\"
			case operatingSystemCommand = "]"
			case startOfString = "X"
			case privacyMessage = "^"
			case applicationProgramCommand = "_"
			case reset = "c"

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
		let (str, didEnd) = self.decodeUTF8(fromData: data, buffer: &dataBuffer)
		self.delegate?.parser(self, didReceiveString: str)
		if didEnd {
			self.delegate?.parserDidEndTransmission(self)
		}
	}

	func reset() {
		textState.reset()
		state = .normal
		dataBuffer = Data()
	}

	private func decodeUTF8(fromData data: Data, buffer: inout Data) -> (decoded: NSAttributedString, didEnd: Bool) {
		let data = buffer + data

		// Parse what we can from the previous leftover and the new data.
		let (str, leftover, didEnd) = self.decodeUTF8(fromData: data)

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

		return (str, didEnd)
	}

	/// Decode UTF-8 string from the given data.
	/// This is a custom implementation that decodes what characters it can then returns whatever it can't,
	/// which is necessary since data can come in arbitrarily-sized chunks of bytes, with characters split
	/// across multiple chunks.
	/// The first time decoding fails, all of the rest of the data will be returned.
	private func decodeUTF8(fromData data: Data) -> (decoded: NSAttributedString, remaining: Data, didEnd: Bool) {
		let byteArray = [UInt8](data)

		var utf8Decoder = UTF8()
		let str = NSMutableAttributedString()
		var byteIterator = byteArray.makeIterator()
		var decodedByteCount = 0
		var didEnd: Bool = false
		Decode: while !didEnd {
			switch utf8Decoder.decode(&byteIterator) {
			case .scalarValue(let v):
				var output: NSAttributedString? = nil
				(output, didEnd) = self.handle(Character(v))
				if let output = output {
					str.append(output)
				}
				decodedByteCount += UTF8.encode(v)!.count
			case .emptyInput, .error:
				break Decode
			}
		}

		let remaining = Data.init(bytes: byteArray.suffix(from: decodedByteCount))
		return (str, remaining, didEnd)
	}

	/// This method is called for each UTF-8 character that is received.
	/// It should perform state changes based on that character, then
	/// return an attributed string that renders the character
	private func handle(_ character: Character) -> (output: NSAttributedString?, didEnd: Bool) {
		// Create a string with the given character
		let str = String.init(character)

		// Try to parse a code
		switch self.state {
		case .normal:
			guard let code = Code.init(rawValue: str) else {
				// While in normal mode, unless we found a code, we should return a string using the current
				// textState's attributes.
				return (NSAttributedString.init(string: str, attributes: textState.attributes), false)
			}
			switch code {
			case .endOfTransmission:
				// Ended transmission, return immediately.
				return (nil, true)
			case .escape:
				self.state = .escape
			default: break
			}
		case .escape:
			if let escapeCode = Code.EscapeCode.init(rawValue: str) {
				switch escapeCode {
				case .controlSequenceIntroducer:
					// We found a CSI sequence.
					self.state = .csiSequence(parameters: "")
				default:
					// Ignore code and return to normal
					self.state = .normal
				}
			} else {
				// Last character was escape, but we didn't find a recognizable code. Return to normal.
				self.state = .normal
			}
		case .csiSequence(let parameters):
			// We are in the middle of parsing a csi sequence

			if let suffix = Code.ControlSequenceSuffix.init(rawValue: str) {
				switch suffix {
				case .selectGraphicRendition:
					textState.parse(escapeCodes: parameters)
				default:
					break
				}
				self.state = .normal
			} else {
				self.state = .csiSequence(parameters: parameters + str)
			}
		}

		// If we made it here, that means that we're in the middle of handling states.
		// No characters are output during this time.
		return (nil, false)
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
