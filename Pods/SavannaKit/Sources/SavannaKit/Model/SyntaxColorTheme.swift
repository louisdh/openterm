//
//  SyntaxTheme.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 24/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public struct LineNumbersStyle {
	
	public let font: Font
	public let textColor: Color
	public let backgroundColor: Color
	
	public init(font: Font, textColor: Color, backgroundColor: Color) {
		self.font = font
		self.textColor = textColor
		self.backgroundColor = backgroundColor
	}

}

public protocol SyntaxColorTheme {
	
	/// Nil hides line numbers.
	var lineNumbersStyle: LineNumbersStyle? { get }
	
	var font: Font { get }
	
	var backgroundColor: Color { get }
	
	func color(for syntaxColorType: SyntaxColorType) -> Color
}

public struct DefaultTheme: SyntaxColorTheme {
	
	private static var lineNumbersColor: Color {
		return Color(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
	}
	
	public let lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: Font(name: "Menlo", size: 16)!, textColor: lineNumbersColor, backgroundColor: Color(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0))

	public let font = Font(name: "Menlo", size: 15)!
	
	public let backgroundColor = Color(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)
	
	public func color(for syntaxColorType: SyntaxColorType) -> Color {
		
		switch syntaxColorType {
		case .plain:
			return .white
			
		case .number:
			return Color(red: 116/255, green: 109/255, blue: 176/255, alpha: 1.0)
			
		case .string:
			return .red
			
		case .identifier:
			return Color(red: 20/255, green: 156/255, blue: 146/255, alpha: 1.0)
			
		case .keyword:
			return Color(red: 215/255, green: 0, blue: 143/255, alpha: 1.0)
			
		case .comment:
			return Color(red: 69.0/255.0, green: 187.0/255.0, blue: 62.0/255.0, alpha: 1.0)
			
		case .editorPlaceholder:
			return backgroundColor
		}
		
	}
	
}

public enum SyntaxColorType {
	case plain
	case number
	case string
	case identifier
	case keyword
	case comment
	case editorPlaceholder
}

