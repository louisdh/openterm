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

protocol InnerTextViewDelegate: class {
	func didUpdateCursorFloatingState()
}

class InnerTextView: TextView {
	
	weak var innerDelegate: InnerTextViewDelegate?
	
	lazy var theme: SyntaxColorTheme = {
		return DefaultTheme()
	}()
	
	var cachedParagraphs: [Paragraph]?
	
	func invalidateCachedParagraphs() {
		cachedParagraphs = nil
	}
	
	func hideGutter() {
		gutterWidth = 0
	}
	
	func updateGutterWidth(for numberOfCharacters: Int) {
		
		let leftInset: CGFloat = 4.0
		let rightInset: CGFloat = 4.0
		
		let charWidth: CGFloat = 10.0
		
		gutterWidth = CGFloat(numberOfCharacters) * charWidth + leftInset + rightInset
		
	}
	
	#if os(iOS)
	
	var isCursorFloating = false
	
	override func beginFloatingCursor(at point: CGPoint) {
		super.beginFloatingCursor(at: point)
		
		isCursorFloating = true
		innerDelegate?.didUpdateCursorFloatingState()

	}
	
	override func endFloatingCursor() {
		super.endFloatingCursor()
		
		isCursorFloating = false
		innerDelegate?.didUpdateCursorFloatingState()

	}
	
	override public func draw(_ rect: CGRect) {
		
		guard let lineNumbersStyle = theme.lineNumbersStyle else {
			hideGutter()
			super.draw(rect)
			return
		}
		
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
		
		lineNumbersStyle.backgroundColor.setFill()
		
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
//	var gutterWidth: CGFloat = 0.0 {
//		didSet {
//
//			textContainer.exclusionPaths = [UIBezierPath(rect: CGRect(x: 0.0, y: 0.0, width: gutterWidth, height: .greatestFiniteMagnitude))]
//
//		}
//
//	}
	
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
