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
	
	let newLineIndices: [Int]
	
	let lexer: Lexer
	
	let tokens: [Token]

	init(source: String) {
		self.source = source
		
		lexer = Lexer(input: source)
		tokens = lexer.tokenize()
		
		newLineIndices = source.newLineIndices
		
	}
	
}

struct CursorInformation {
	
	let sourceInfo: SourceInformation
	
	var source: String {
		return sourceInfo.source
	}
	
	var newLineIndices: [Int] {
		return sourceInfo.newLineIndices
	}
	
	let globalCursor: Int
	let lineNumber: Int
	let lineCursor: Int
	let lineSource: String
	
	var textOnLineBeforeCursor: String
	
	var lexer: Lexer {
		return sourceInfo.lexer
	}
	
	var tokens: [Token] {
		return sourceInfo.tokens
	}
	
	var currentToken: Token?
	
	init(sourceInfo: SourceInformation, cursor: Int) {
		self.sourceInfo = sourceInfo
		
		globalCursor = cursor
		
		lineNumber = sourceInfo.source.lineNumber(of: cursor)
		
		lineSource = sourceInfo.source.getLine(lineNumber, newLineIndices: sourceInfo.newLineIndices)
		
		var indexInLine = cursor
		
		if lineNumber > 1 {
			for i in 1..<lineNumber {
				// count + 1 because of "\n"
				indexInLine -= (sourceInfo.source.getLine(i, newLineIndices: sourceInfo.newLineIndices).count + 1)
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

fileprivate struct Cached<T> {
	
	let source: String
	let cache: T
	
}

public class AutoCompleter {
	
	fileprivate var cachedSourceInfo: Cached<SourceInformation>?
	fileprivate var cachedCursorInfo: Cached<CursorInformation>?
	
	public init() {
		
	}
	
	public func completionSuggestions(for source: String, cursor: Int) -> [CompletionSuggestion] {
		
		let sourceInfo: SourceInformation
		let cursorInfo: CursorInformation

		if let cached = cachedSourceInfo, cached.source == source {
			
			sourceInfo = cached.cache
			
			if let cachedCursorInfo = self.cachedCursorInfo, cachedCursorInfo.cache.globalCursor == cursor {
				
				cursorInfo = cachedCursorInfo.cache
				
			} else {
				
				cursorInfo = CursorInformation(sourceInfo: sourceInfo, cursor: cursor)
				cachedCursorInfo = Cached(source: source, cache: cursorInfo)
				
			}

		} else {
			
			sourceInfo = SourceInformation(source: source)
			cursorInfo = CursorInformation(sourceInfo: sourceInfo, cursor: cursor)
			
			cachedSourceInfo = Cached(source: source, cache: sourceInfo)
			
		}
		
		var suggestions = [CompletionSuggestion]()
		
		if !cursorInfo.textOnLineBeforeCursor.isEmpty {
			
			for keyword in Lexer.keywordTokens.keys {
				
				if keyword.hasPrefix(String(cursorInfo.textOnLineBeforeCursor)) {
					
					let startIndex = keyword.index(keyword.startIndex, offsetBy: cursorInfo.textOnLineBeforeCursor.count)
					let content = String(keyword[startIndex...])
					
					let suggestion = CompletionSuggestion(title: keyword, content: content, insertionIndex: cursor, cursorAfterInsertion: content.count)
					suggestions.append(suggestion)
					
				}
				
			}
			
		}
		
		if cursorInfo.textOnLineBeforeCursor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			let statementSuggestions = self.statementSuggestions(cursor: cursor, prefix: cursorInfo.textOnLineBeforeCursor)
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
		
		let whileStatement = CompletionSuggestion(title: "while ...", content: whileContent, insertionIndex: cursor, cursorAfterInsertion: 7)
		suggestions.append(whileStatement)
	
		var forContent = ""
		forContent += "for <#initialization"
		forContent += "#>, <#condition"
		forContent += "#>, <#increment"
		forContent += "#> {\n"
		forContent += "\(prefix)\t<#body"
		forContent += "#>\n"
		forContent += "\(prefix)}"
		
		let forStatement = CompletionSuggestion(title: "for ...", content: forContent, insertionIndex: cursor, cursorAfterInsertion: 4)
		suggestions.append(forStatement)
		
		return suggestions

	}

}
