//
//  SyntaxTextView+TextViewDelegate.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 17/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

extension SyntaxTextView {

	func isEditorPlaceholderSelected(selectedRange: NSRange, tokenRange: NSRange) -> Bool {
		
		var intersectionRange = tokenRange
		intersectionRange.location += 1
		intersectionRange.length -= 1
		
		return selectedRange.intersection(intersectionRange) != nil
	}
	
	func updateSelectedRange(_ range: NSRange) {
		textView.selectedRange = range
		self.delegate?.didChangeSelectedRange(self, selectedRange: range)
	}
	
	func selectionDidChange() {
		
		guard let delegate = delegate else {
			return
		}
		
		if let cachedTokens = cachedTokens {
			
			for cachedToken in cachedTokens {
				
				guard let range = cachedToken.nsRange else {
					continue
				}
				
				if case .editorPlaceholder = cachedToken.token.savannaTokenType.syntaxColorType {
					
					var forceInsideEditorPlaceholder = true
					
					let currentSelectedRange = textView.selectedRange
					
					if let previousSelectedRange = previousSelectedRange {
						
						if isEditorPlaceholderSelected(selectedRange: currentSelectedRange, tokenRange: range) {
						
							// Going right.
							if previousSelectedRange.location + 1 == currentSelectedRange.location {
								
								if isEditorPlaceholderSelected(selectedRange: previousSelectedRange, tokenRange: range) {
									updateSelectedRange(NSRange(location: range.location+range.length, length: 0))
								} else {
									updateSelectedRange(NSRange(location: range.location + 1, length: 0))
								}
								
								forceInsideEditorPlaceholder = false
								break
							}
							
							// Going left.
							if previousSelectedRange.location - 1 == currentSelectedRange.location {

								if isEditorPlaceholderSelected(selectedRange: previousSelectedRange, tokenRange: range) {
									updateSelectedRange(NSRange(location: range.location, length: 0))
								} else {
									updateSelectedRange(NSRange(location: range.location + 1, length: 0))
								}
								
								forceInsideEditorPlaceholder = false
								break
							}
							
						}
						
					}
					
					if forceInsideEditorPlaceholder {
						if isEditorPlaceholderSelected(selectedRange: currentSelectedRange, tokenRange: range) {
							
							if currentSelectedRange.location <= range.location || currentSelectedRange.upperBound >= range.upperBound {
								// Editor placeholder is part of larger selected text,
								// so don't change selection.
								break
							}
							
							updateSelectedRange(NSRange(location: range.location+1, length: 0))
							break
						}
					}
					
				}
				
			}
			
		}
		
		colorTextView(lexerForSource: { (source) -> Lexer in
			return delegate.lexerForSource(source)
		})
		
		previousSelectedRange = textView.selectedRange
		
	}
	
}

#if os(macOS)
	
	extension SyntaxTextView: NSTextViewDelegate {
		
		public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
			
			let text = replacementString ?? ""
			
			return self.shouldChangeText(insertingText: text)
		}
		
		public func textDidChange(_ notification: Notification) {
			guard let textView = notification.object as? NSTextView, textView == self.textView else {
				return
			}
			
			didUpdateText()
			
		}
		
		func didUpdateText() {
			
			self.invalidateCachedTokens()
			self.textView.invalidateCachedParagraphs()
			
			if let delegate = delegate {
				colorTextView(lexerForSource: { (source) -> Lexer in
					return delegate.lexerForSource(source)
				})
			}
			
			wrapperView.setNeedsDisplay(wrapperView.bounds)
			self.delegate?.didChangeText(self)
			
		}
		
		public func textViewDidChangeSelection(_ notification: Notification) {
			
			contentDidChangeSelection()

		}
		
	}
	
#endif

#if os(iOS)
	
	extension SyntaxTextView: UITextViewDelegate {
		
		public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
			
			return self.shouldChangeText(insertingText: text)
		}
		
		public func textViewDidChange(_ textView: UITextView) {
			
			didUpdateText()
			
		}
		
		func didUpdateText() {
			
			self.invalidateCachedTokens()
			self.textView.invalidateCachedParagraphs()
			textView.setNeedsDisplay()
			
			if let delegate = delegate {
				colorTextView(lexerForSource: { (source) -> Lexer in
					return delegate.lexerForSource(source)
				})
			}
			
			self.delegate?.didChangeText(self)
			
		}
	
		public func textViewDidChangeSelection(_ textView: UITextView) {
			
			contentDidChangeSelection()
		}
		
	}
	
#endif

extension SyntaxTextView {

	func shouldChangeText(insertingText: String) -> Bool {

		let textStorage: NSTextStorage
		
		#if os(macOS)
		
		guard let _textStorage = textView.textStorage else {
			return true
		}
		
		textStorage = _textStorage
		
		#else
		
		textStorage = textView.textStorage
		#endif
		
		guard let cachedTokens = cachedTokens else {
			return true
		}
			
		for token in cachedTokens {
			
			guard let range = token.nsRange else {
				continue
			}
			
			if case .editorPlaceholder = token.token.savannaTokenType.syntaxColorType {
				
				let selectedRange = textView.selectedRange

				if isEditorPlaceholderSelected(selectedRange: selectedRange, tokenRange: range) {
					
					if insertingText == "\t" {
						
						let placeholderTokens = cachedTokens.filter({
							$0.token.savannaTokenType.syntaxColorType == .editorPlaceholder
						})
						
						guard placeholderTokens.count > 1 else {
							return false
						}
						
						let nextPlaceholderToken = placeholderTokens.first(where: {
							
							guard let nsRange = $0.nsRange else {
								return false
							}
							
							return nsRange.lowerBound > range.lowerBound
							
						})
						
						if let tokenToSelect = nextPlaceholderToken ?? placeholderTokens.first {
							
							updateSelectedRange(NSRange(location: tokenToSelect.nsRange!.lowerBound + 1, length: 0))
							
							return false
							
						}
						
						return false
					}
					
					if selectedRange.location <= range.location || selectedRange.upperBound >= range.upperBound {
						// Editor placeholder is part of larger selected text,
						// so allow system inserting.
						return true
					}
					
					textStorage.replaceCharacters(in: range, with: insertingText)

					didUpdateText()
					
					return false
				}
				
			}
			
		}
		
		return true
	}
	
	func contentDidChangeSelection() {
		
		if ignoreSelectionChange {
			return
		}
		
		ignoreSelectionChange = true
		
		selectionDidChange()
		
		ignoreSelectionChange = false
		
	}
	
}
