//
//  ANSITextState.swift
//  OpenTerm
//
//  Created by Ian McDowell on 1/31/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

// 0-  7:  standard colors (as in ESC [ 30–37 m)
// 8- 15:  high intensity colors (as in ESC [ 90–97 m)
private let colors: [(r: Int, g: Int, b: Int)] = [
	/* Normal colors */
	(0x00, 0x00, 0x00), /* Black   */
	(0x99, 0x3E, 0x3E), /* Red     */
	(0x3E, 0x99, 0x3E), /* Green   */
	(0x99, 0x99, 0x3E), /* Brown   */
	(0x3E, 0x3E, 0x99), /* Blue    */
	(0x99, 0x3E, 0x99), /* Magenta */
	(0x3E, 0x99, 0x99), /* Cyan    */
	(0x99, 0x99, 0x99), /* White   */

	/* Intense colors */
	(0x3E, 0x3E, 0x3E), /* Black   */
	(0xFF, 0x67, 0x67), /* Red     */
	(0x67, 0xFF, 0x67), /* Green   */
	(0xFF, 0xFF, 0x67), /* Brown   */
	(0x67, 0x67, 0xFF), /* Blue    */
	(0xFF, 0x67, 0xFF), /* Magenta */
	(0x67, 0xFF, 0xFF), /* Cyan    */
	(0xFF, 0xFF, 0xFF), /* White   */
]

func indexedColor(atIndex index: Int) -> UIColor {
	guard index >= 0 && index <= 255 else { fatalError("Index out of bounds.") }
	let r, g, b: Int
	if index < 16 {
		(r, g, b) = colors[index]
	} else if index < 232 {
		// 16-231 (216 colors in 6x6x6 cube)
		let offset = Double(index - 16)
		let boxSize: Int = 6
		let v = [0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff]
		r = v[Int(offset / Double(boxSize * boxSize)) % boxSize | 0]
		g = v[Int(offset / Double(boxSize)) % boxSize | 0]
		b = v[Int(offset) % boxSize]
	} else {
		// 232-255 (greyscale)
		let offset = index - 232
		let value = 8 + offset * 10
		(r, g, b) = (value, value, value)
	}
	return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
}

func customColor(codes: [Int]) -> (color: UIColor, readCount: Int) {
	// Two supported cases:
	// - 5;n => 8-bit 0-255 color
	// - 2;r;g;b => RGB color
	let invalidResponse: (UIColor, Int) = (.clear, 0)

	switch codes.first ?? 0 {
	case 5:
		let expectedCodes = 2
		guard codes.count >= expectedCodes else { return invalidResponse }
		let value = codes[1]

		guard value <= 255 else { return invalidResponse }
		let color = indexedColor(atIndex: value)
		return (color, expectedCodes)
	case 2:
		let expectedCodes = 4
		guard codes.count >= expectedCodes else { return invalidResponse }
		let r = codes[1]
		let g = codes[2]
		let b = codes[3]
		let color = UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
		return (color, expectedCodes)
	default:
		return invalidResponse
	}
}

enum ANSIForegroundColor: Int {
	case `default` = 39
	case black = 30
	case red = 31
	case green = 32
	case yellow = 33
	case blue = 34
	case purple = 35
	case cyan = 36
	case white = 37

	case blackBright = 90
	case redBright = 91
	case greenBright = 92
	case yellowBright = 93
	case blueBright = 94
	case purpleBright = 95
	case cyanBright = 96
	case whiteBright = 97

	// custom color (either 8-bit 0-255, or rgb)
	static let custom: Int = 38

	var color: UIColor {
		switch self.rawValue {
		case ANSIForegroundColor.default.rawValue:
			return UserDefaultsController.shared.terminalTextColor
		case 30...37:
			return indexedColor(atIndex: self.rawValue - 30)
		case 90...97:
			return indexedColor(atIndex: self.rawValue - 80)
		default:
			fatalError("Invalid value")
		}
	}
}

enum ANSIBackgroundColor: Int {
	case `default` = 49
	case black = 40
	case red = 41
	case green = 42
	case yellow = 43
	case blue = 44
	case purple = 45
	case cyan = 46
	case white = 47

	case blackBright = 100
	case redBright = 101
	case greenBright = 102
	case yellowBright = 103
	case blueBright = 104
	case purpleBright = 105
	case cyanBright = 106
	case whiteBright = 107

	// custom color (either 8-bit 0-255, or rgb)
	static let custom: Int = 48

	var color: UIColor {
		switch self.rawValue {
		case ANSIBackgroundColor.default.rawValue:
			return .clear
		case 40...47:
			return indexedColor(atIndex: self.rawValue - 40)
		case 100...107:
			return indexedColor(atIndex: self.rawValue - 90)
		default:
			fatalError("Invalid value")
		}
	}
}

enum ANSIFontState: Int {
	case bold = 1
	case noBold = 21

	case faint = 2
	case noFaint = 22

	case italic = 3
	case noItalic = 23

	case underline = 4
	case noUnderline = 24

	case crossedOut = 9
	case noCrossedOut = 29
}

struct ANSITextState {
	var foregroundColor: UIColor = UserDefaultsController.shared.terminalTextColor
	var backgroundColor: UIColor = UserDefaultsController.shared.terminalBackgroundColor
	var isUnderlined: Bool = false
	var isStrikethrough: Bool = false
	var font: UIFont = ANSITextState.font(fromTraits: [])
	var fontTraits: UIFontDescriptorSymbolicTraits = [] {
		didSet {
			self.font = ANSITextState.font(fromTraits: fontTraits)
		}
	}

	var attributes: [NSAttributedStringKey: Any] {
		return [
			.foregroundColor: foregroundColor,
			.backgroundColor: backgroundColor,
			.underlineStyle: isUnderlined ? NSUnderlineStyle.styleSingle.rawValue : NSUnderlineStyle.styleNone.rawValue,
			.underlineColor: foregroundColor,
			.strikethroughStyle: isStrikethrough ? NSUnderlineStyle.styleSingle.rawValue : NSUnderlineStyle.styleNone.rawValue,
			.strikethroughColor: foregroundColor,
			.font: font
		]
	}

	private static func font(fromTraits traits: UIFontDescriptorSymbolicTraits) -> UIFont {
		let textSize = CGFloat(UserDefaultsController.shared.terminalFontSize)
		var descriptor = UIFontDescriptor(name: "Menlo", size: textSize)
		if let traitDescriptor = descriptor.withSymbolicTraits(traits) {
			descriptor = traitDescriptor
		}
		return UIFont(descriptor: descriptor, size: textSize)
	}

	mutating func reset() {
		foregroundColor = UserDefaultsController.shared.terminalTextColor
		backgroundColor = UserDefaultsController.shared.terminalBackgroundColor
		isUnderlined = false
		isStrikethrough = false
		fontTraits = []
	}

	mutating func parse(escapeCodes: String) {
		// Codes will be a colon-separated string of integers. For each one, adjust our state
		let codes = escapeCodes.components(separatedBy: ";").flatMap { Int($0) }
		var index = codes.startIndex
		while index < codes.endIndex {
			let code = codes[index]
			var readCount = 1

			// Reset code = reset all state
			if code == 0 {
				
				reset()
				
			} else if let foregroundColor = ANSIForegroundColor(rawValue: code) {
				
				self.foregroundColor = foregroundColor.color
				
			} else if code == ANSIForegroundColor.custom {
				
				let result = customColor(codes: Array(codes.suffix(from: index + 1)))
				readCount += result.readCount
				foregroundColor = result.color
				
			} else if let backgroundColor = ANSIBackgroundColor(rawValue: code) {
				self.backgroundColor = backgroundColor.color
				
			} else if code == ANSIBackgroundColor.custom {
				
				let result = customColor(codes: Array(codes.suffix(from: index + 1)))
				readCount += result.readCount
				backgroundColor = result.color
				
			} else if let fontState = ANSIFontState(rawValue: code) {
				switch fontState {
				case .bold: fontTraits.insert(.traitBold)
				case .noBold: fontTraits.remove(.traitBold)
				case .faint: break
				case .noFaint: break
				case .italic: fontTraits.insert(.traitItalic)
				case .noItalic: fontTraits.remove(.traitItalic)
				case .underline: isUnderlined = true
				case .noUnderline: isUnderlined = false
				case .crossedOut: isStrikethrough = true
				case .noCrossedOut: isStrikethrough = false
				}
			}

			index += readCount
		}
	}
}
