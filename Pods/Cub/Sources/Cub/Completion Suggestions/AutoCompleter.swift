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
	public var content: String
	
	/// Where this suggestion's content should be inserted,
	/// in the source code.
	/// This index is in terms of Swift characters.
	public let insertionIndex: Int
	
	/// Relative to the suggestion.
	/// This index is in terms of Swift characters.
	public var cursorAfterInsertion: Int
	
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
	var textInWordBeforeCursor: String

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
		
		textOnLineBeforeCursor = String(lineSource[..<lineSource.index(lineSource.startIndex, offsetBy: indexInLine)])
		
		textInWordBeforeCursor = ""
		
		for char in textOnLineBeforeCursor {
			
			textInWordBeforeCursor += String(char)
			
			if char == " " || char  == "\t" {
				textInWordBeforeCursor = ""
			}
		}
		
		
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
					textInWordBeforeCursor = ""
					
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
	
	let documentation: [DocumentationItem]
	
	public init(documentation: [DocumentationItem] = []) {
		
		self.documentation = documentation
		
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
		
		if !cursorInfo.textInWordBeforeCursor.isEmpty {
			
			for keyword in Lexer.keywordTokens.keys {
				
				if keyword.hasPrefix(String(cursorInfo.textInWordBeforeCursor)) {
					
					let startIndex = keyword.index(keyword.startIndex, offsetBy: cursorInfo.textInWordBeforeCursor.count)
					let content = String(keyword[startIndex...])
					
					let suggestion = CompletionSuggestion(title: keyword, content: content, insertionIndex: cursor, cursorAfterInsertion: content.count)
					suggestions.append(suggestion)
					
				}
				
			}
			
		}
		
		var editorPlaceholderTitle: String?
		
		if let currentToken = cursorInfo.currentToken, case let .editorPlaceholder(value) = currentToken.type {
			editorPlaceholderTitle = value
		}
		
		let legalEditorPlaceholdersForStatements = ["body"]
		
		let suggestStatements: Bool

		if let editorPlaceholderTitle = editorPlaceholderTitle {
			
			suggestStatements = legalEditorPlaceholdersForStatements.contains(editorPlaceholderTitle)
			
		} else {
			
			suggestStatements = true
		}
		
		if suggestStatements {
			
			var indentationWhitespace = ""
			
			for char in cursorInfo.textOnLineBeforeCursor {
				
				if char == "\t" {
					indentationWhitespace += "\t"
				} else if char == " " {
					indentationWhitespace += " "
				} else {
					break
				}
				
			}
			
			let statementSuggestions = self.statementSuggestions(cursor: cursor, prefix: indentationWhitespace)

			suggestions.append(contentsOf: statementSuggestions.filter({ $0.content.hasPrefix(cursorInfo.textInWordBeforeCursor) }))
		}
		
		for docItem in documentation {
			suggestions.append(documentationSuggestions(cursor: cursor, docItem: docItem))
		}
		
		var filteredSuggestions = suggestions.filter({ $0.content.hasPrefix(cursorInfo.textInWordBeforeCursor) && $0.content != cursorInfo.textInWordBeforeCursor })
		
		for idx in filteredSuggestions.indices {
			filteredSuggestions[idx].content.removeFirst(cursorInfo.textInWordBeforeCursor.count)
			filteredSuggestions[idx].cursorAfterInsertion -= cursorInfo.textInWordBeforeCursor.count
		}
		
		return filteredSuggestions
	}

	private func documentationSuggestions(cursor: Int, docItem: DocumentationItem) -> CompletionSuggestion {
		
		switch docItem.type {
		case .function(let funcDoc):
			
			var content = funcDoc.name + "("
			
			let argPlaceholders = funcDoc.arguments.map({
				return "<#" +
						$0 +
						"#>"
			})
			
			content.append(argPlaceholders.joined(separator: ", "))
		
			content += ")"
			
			let cursorAfterInsertion: Int
			
			if funcDoc.arguments.isEmpty {
				cursorAfterInsertion = content.count
			} else {
				cursorAfterInsertion = funcDoc.name.count + 3
			}
			
			return CompletionSuggestion(title: funcDoc.name + "(...)", content: content, insertionIndex: cursor, cursorAfterInsertion: cursorAfterInsertion)
		
		case .variable(let varDoc):

			let content = varDoc.name
			
			return CompletionSuggestion(title: varDoc.name, content: content, insertionIndex: cursor, cursorAfterInsertion: content.count)
		
		case .struct(let structDoc):

			var content = structDoc.name + "("
			
			let memberPlaceholders = structDoc.members.map({
				return "<#" +
					$0 +
				"#>"
			})
			
			content.append(memberPlaceholders.joined(separator: ", "))
			
			content += ")"
			
			let cursorAfterInsertion: Int

			if structDoc.members.isEmpty {
				cursorAfterInsertion = content.count
			} else {
				cursorAfterInsertion = structDoc.name.count + 3
			}
			
			return CompletionSuggestion(title: structDoc.name + "(...)", content: content, insertionIndex: cursor, cursorAfterInsertion: cursorAfterInsertion)
		}
		
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
		
		let forStatement = CompletionSuggestion(title: "for ...", content: forContent, insertionIndex: cursor, cursorAfterInsertion: 5)
		suggestions.append(forStatement)
		
		var varContent = ""
		varContent += "<#name"
		varContent += "#> = <#value"
		varContent += "#>"
		
		let varStatement = CompletionSuggestion(title: "var ...", content: varContent, insertionIndex: cursor, cursorAfterInsertion: 1)
		suggestions.append(varStatement)
		
		return suggestions

	}

}
