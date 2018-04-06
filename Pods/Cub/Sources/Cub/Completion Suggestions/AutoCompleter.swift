//
//  AutoCompleter.swift
//  Cub
//
//  Created by Louis D'hauwe on 17/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

/// A completion suggestion describes source code
/// that can be inserted in a user's source code.
public struct CompletionSuggestion {
	
	/// A title describing the suggestion.
	public let title: String
	
	/// The source code to be inserted.
	public let content: String
	
	/// Where this suggestion's content should be inserted,
	/// in the source code.
	public let insertionIndex: Int
	
	/// Relative to the suggestion.
	public let cursorAfterInsertion: Int
	
}

extension CompletionSuggestion: Equatable {
	
	public static func ==(lhs: CompletionSuggestion, rhs: CompletionSuggestion) -> Bool {
		return lhs.content == rhs.content &&
			lhs.insertionIndex == rhs.insertionIndex &&
			lhs.title == rhs.title &&
			lhs.cursorAfterInsertion == rhs.cursorAfterInsertion
	}
	
}

public class AutoCompleter {
	
	public init() {
		
	}
	
	public func completionSuggestions(for source: String, cursor: Int) -> [CompletionSuggestion] {
		
		var suggestions = [CompletionSuggestion]()
		
		let lexer = Lexer(input: source)
		
		let tokens = lexer.tokenize()
		
//		var previousToken: Token?
		var currentToken: Token?
		
		for token in tokens {
			
			guard let range = token.range else {
				continue
			}
			
			if range.lowerBound > cursor || range.contains(cursor) {
				currentToken = token
				break
			}
			
//			previousToken = token
		}
		
		let currentLineIndex = source.lineNumber(of: cursor)
		
		let currentLine = source.getLine(currentLineIndex)
		
		var indexInLine = cursor
		
		if currentLineIndex > 1 {
			for i in 1..<currentLineIndex {
				// count + 1 because of "\n"
				indexInLine -= (source.getLine(i).count + 1)
			}
		}
		
		var textOnLineBeforeCursor = currentLine[currentLine.startIndex..<currentLine.index(currentLine.startIndex, offsetBy: indexInLine)]
		
		if !textOnLineBeforeCursor.isEmpty {
			
			for keyword in Lexer.keywordTokens.keys {
				
				if keyword.hasPrefix(String(textOnLineBeforeCursor)) {
					
					let startIndex = keyword.index(keyword.startIndex, offsetBy: textOnLineBeforeCursor.count)
					let content = String(keyword[startIndex...])
					
					let suggestion = CompletionSuggestion(title: keyword, content: content, insertionIndex: cursor, cursorAfterInsertion: content.count)
					suggestions.append(suggestion)
					
				}
				
			}
			
		}
		
		if let currentToken = currentToken {
			
			if case .editorPlaceholder = currentToken.type {
				
				if let range = currentToken.range, range.contains(cursor) {
					
					textOnLineBeforeCursor.removeLast(cursor - range.lowerBound)
					
				}
				
			}
			
		}
		
		if textOnLineBeforeCursor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			let statementSuggestions = self.statementSuggestions(cursor: cursor, prefix: String(textOnLineBeforeCursor))
			suggestions.append(contentsOf: statementSuggestions)
		}

		return suggestions
	}
	
	private func statementSuggestions(cursor: Int, prefix: String) -> [CompletionSuggestion] {
		
		var suggestions = [CompletionSuggestion]()

		var ifContent = ""
		ifContent += "if <#condition"
		ifContent += "#> {\n"
		ifContent += "\(prefix)\t<#body"
		ifContent += "#>\n"
		ifContent += "\(prefix)}"
		
		let ifStatement = CompletionSuggestion(title: "if ...", content: ifContent, insertionIndex: cursor, cursorAfterInsertion: 4)
		suggestions.append(ifStatement)
		
		var whileContent = ""
		whileContent += "while <#condition"
		whileContent += "#> {\n"
		whileContent += "\(prefix)\t<#body"
		whileContent += "#>\n"
		whileContent += "\(prefix)}"
		
		let whileStatement = CompletionSuggestion(title: "while ...", content: whileContent, insertionIndex: cursor, cursorAfterInsertion: 6)
		suggestions.append(whileStatement)
		
		return suggestions

	}

}
