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
public struct CompletionSuggestion: Equatable {
	
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

struct SourceInformation {
	
	let source: String
	let globalCursor: Int
	let lineNumber: Int
	let lineCursor: Int
	let lineSource: String
	
	let newLineIndices: [Int]
	
	var textOnLineBeforeCursor: String
	
	let lexer: Lexer
	
	let tokens: [Token]

	var currentToken: Token?

	init(source: String, cursor: Int) {
		self.source = source
		globalCursor = cursor
		
		lexer = Lexer(input: source)
		tokens = lexer.tokenize()
		
		newLineIndices = source.newLineIndices
		
		lineNumber = source.lineNumber(of: cursor)
		
		lineSource = source.getLine(lineNumber, newLineIndices: newLineIndices)
		
		var indexInLine = cursor
		
		if lineNumber > 1 {
			for i in 1..<lineNumber {
				// count + 1 because of "\n"
				indexInLine -= (source.getLine(i, newLineIndices: newLineIndices).count + 1)
			}
		}
		
		lineCursor = indexInLine
		
		textOnLineBeforeCursor = String(lineSource[lineSource.startIndex..<lineSource.index(lineSource.startIndex, offsetBy: indexInLine)])

		
//		var previousToken: Token?
		
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
		
		if let currentToken = currentToken {
			
			if case .editorPlaceholder = currentToken.type {
				
				if let range = currentToken.range, range.contains(cursor) {
					
					textOnLineBeforeCursor.removeLast(cursor - range.lowerBound)
					
				}
				
			}
			
		}
		
	}
	
}

public class AutoCompleter {
	
	public init() {
		
	}
	
	public func completionSuggestions(for source: String, cursor: Int) -> [CompletionSuggestion] {
		
		var suggestions = [CompletionSuggestion]()
		
		let sourceInfo = SourceInformation(source: source, cursor: cursor)
		
		if !sourceInfo.textOnLineBeforeCursor.isEmpty {
			
			for keyword in Lexer.keywordTokens.keys {
				
				if keyword.hasPrefix(String(sourceInfo.textOnLineBeforeCursor)) {
					
					let startIndex = keyword.index(keyword.startIndex, offsetBy: sourceInfo.textOnLineBeforeCursor.count)
					let content = String(keyword[startIndex...])
					
					let suggestion = CompletionSuggestion(title: keyword, content: content, insertionIndex: cursor, cursorAfterInsertion: content.count)
					suggestions.append(suggestion)
					
				}
				
			}
			
		}
		
		if sourceInfo.textOnLineBeforeCursor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			let statementSuggestions = self.statementSuggestions(cursor: cursor, prefix: sourceInfo.textOnLineBeforeCursor)
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
