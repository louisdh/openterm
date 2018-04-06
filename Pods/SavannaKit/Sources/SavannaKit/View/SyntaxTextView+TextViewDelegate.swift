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

	func selectionDidChange() {
		
		guard let delegate = delegate else {
			return
		}
		
		if let cachedTokens = cachedTokens {
			
			for token in cachedTokens {
				
				guard let tokenRange = token.range else {
					continue
				}
				
				guard let range = textView.text.nsRange(fromRange: tokenRange) else {
					continue
				}
				
				if case .editorPlaceholder = token.savannaTokenType.syntaxColorType {
					
					var forceInsideEditorPlaceholder = true
					
					let currentSelectedRange = textView.selectedRange
					
					if let previousSelectedRange = previousSelectedRange {
						
						if currentSelectedRange.intersection(range) != nil, previousSelectedRange.intersection(range) != nil {

							if previousSelectedRange.location + 1 == currentSelectedRange.location {
								
								textView.selectedRange = NSRange(location: range.location+range.length, length: 0)
								
								forceInsideEditorPlaceholder = false
								break
							}
							
							if previousSelectedRange.location - 1 == currentSelectedRange.location {

								textView.selectedRange = NSRange(location: range.location-1, length: 0)
								
								forceInsideEditorPlaceholder = false
								break
							}
							
						}
						
					}
					
					if forceInsideEditorPlaceholder {
						if currentSelectedRange.intersection(range) != nil {
							textView.selectedRange = NSRange(location: range.location+1, length: 0)
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
			
			if let cachedTokens = cachedTokens {
				
				for token in cachedTokens {
					
					guard let tokenRange = token.range else {
						continue
					}
					
					guard let range = textView.text.nsRange(fromRange: tokenRange) else {
						continue
					}
					
					if case .editorPlaceholder = token.savannaTokenType.syntaxColorType {
						
						let selectedRange = textView.selectedRange
						
						if selectedRange.intersection(range) != nil {
							
							textView.textStorage?.replaceCharacters(in: range, with: text)
							didUpdateText()
							
							return false
						} else if selectedRange.length == 0, selectedRange.location == range.upperBound {
							
							textView.textStorage?.replaceCharacters(in: range, with: text)
							
							textView.selectedRange = NSRange(location: range.lowerBound, length: 0)
							
							didUpdateText()
							
							return false
						}
						
					}
					
				}
				
			}
			
			
			return true
			
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
			
			if ignoreSelectionChange {
				return
			}
			
			ignoreSelectionChange = true

			selectionDidChange()
			
			ignoreSelectionChange = false

		}
		
	}
	
#endif

#if os(iOS)
	
	extension SyntaxTextView: UITextViewDelegate {
		
		public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
			
			if let cachedTokens = cachedTokens {
				
				for token in cachedTokens {
					
					guard let tokenRange = token.range else {
						continue
					}
					
					guard let range = textView.text.nsRange(fromRange: tokenRange) else {
						continue
					}
					
					if case .editorPlaceholder = token.savannaTokenType.syntaxColorType {
						
						let selectedRange = textView.selectedRange
						
						if selectedRange.intersection(range) != nil {

							textView.textStorage.replaceCharacters(in: range, with: text)
							didUpdateText()

							return false
						} else if selectedRange.length == 0, selectedRange.location == range.upperBound {
							
							textView.textStorage.replaceCharacters(in: range, with: text)
							
							textView.selectedRange = NSRange(location: range.lowerBound, length: 0)
							
							didUpdateText()
							
							return false
						}
						
					}
					
				}
				
			}
			
			
			return true
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
			
			selectionDidChange()
			
		}
		
	}
	
#endif
