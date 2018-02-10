//
//  Paragraph.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 24/06/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

struct Paragraph {
	
	var rect: CGRect
	let number: Int
	
	var string: String {
		return "\(number)"
	}
	
	func attributedString(for theme: SyntaxColorTheme) -> NSAttributedString {
		
		let attr = NSMutableAttributedString(string: string)
		let range = NSMakeRange(0, attr.length)
		
		let attributes: [NSAttributedStringKey: Any] = [
			.font: theme.lineNumbersStyle.font,
			.foregroundColor : theme.lineNumbersStyle.textColor
		]
		
		attr.addAttributes(attributes, range: range)
		
		return attr
	}
	
	func drawSize(for theme: SyntaxColorTheme) -> CGSize {
		return attributedString(for: theme).size()
	}
	
}

