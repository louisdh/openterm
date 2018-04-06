//
//  InnerTextView.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 09/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

class InnerTextView: TextView {
	
	lazy var theme: SyntaxColorTheme = {
		return DefaultTheme()
	}()
	
	var cachedParagraphs: [Paragraph]?
	
	func invalidateCachedParagraphs() {
		cachedParagraphs = nil
	}
	
	func updateGutterWidth(for numberOfCharacters: Int) {
		
		let leftInset: CGFloat = 4.0
		let rightInset: CGFloat = 4.0
		
		let charWidth: CGFloat = 10.0
		
		gutterWidth = CGFloat(numberOfCharacters) * charWidth + leftInset + rightInset
		
	}
	
	#if os(iOS)
	override public func draw(_ rect: CGRect) {
		
		let textView = self
		
		var paragraphs: [Paragraph]
		
		if let cached = textView.cachedParagraphs {
			
			paragraphs = cached
			
		} else {
			
			paragraphs = generateParagraphs(for: textView, flipRects: false)
			textView.cachedParagraphs = paragraphs
			
		}
		
		let components = textView.text.components(separatedBy: .newlines)
		
		let count = components.count
		
		let maxNumberOfDigits = "\(count)".count
		
		textView.updateGutterWidth(for: maxNumberOfDigits)
		
		Color.black.setFill()
		
		let gutterRect = CGRect(x: 0, y: rect.minY, width: textView.gutterWidth, height: rect.height)
		let path = BezierPath(rect: gutterRect)
		path.fill()
		
		
		drawLineNumbers(paragraphs, in: self.bounds, for: self)
		
		super.draw(rect)
	}
	#endif
	
	var gutterWidth: CGFloat {
		set {
			
			#if os(macOS)
				textContainerInset = NSSize(width: newValue, height: 0)
			#else
				textContainerInset = UIEdgeInsets(top: 0, left: newValue, bottom: 0, right: 0)
			#endif
			
		}
		get {
			
			#if os(macOS)
				return textContainerInset.width
			#else
				return textContainerInset.left
			#endif
			
		}
	}
	
	#if os(iOS)
	
	override func caretRect(for position: UITextPosition) -> CGRect {
		
		var superRect = super.caretRect(for: position)
		
		let font = self.theme.font
		
		// "descender" is expressed as a negative value,
		// so to add its height you must subtract its value
		superRect.size.height = font.pointSize - font.descender
		
		return superRect
	}
	
	#endif
	
}
