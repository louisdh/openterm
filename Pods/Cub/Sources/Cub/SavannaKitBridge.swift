//
//  SavannaKitBridge.swift
//  Cub
//
//  Created by Louis D'hauwe on 10/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

#if canImport(SavannaKit)

import SavannaKit

extension Cub.TokenType: SavannaKit.TokenType {
	
	public var syntaxColorType: SyntaxColorType {
		
		switch self {
		case .booleanAnd, .booleanNot, .booleanOr:
			return .plain
			
		case .shortHandAdd, .shortHandDiv, .shortHandMul, .shortHandPow, .shortHandSub:
			return .plain
			
		case .equals, .notEqual, .dot, .ignoreableToken, .parensOpen, .parensClose, .curlyOpen, .curlyClose, .comma:
			return .plain
			
		case .comparatorEqual, .comparatorLessThan, .comparatorGreaterThan, .comparatorLessThanEqual, .comparatorGreaterThanEqual:
			return .plain
			
		case .string:
			return .string
			
		case .other:
			return .plain
			
		case .break, .continue, .function, .if, .else, .while, .for, .do, .times, .return, .returns, .repeat, .true, .false, .struct, .guard, .in, .nil:
			return .keyword
			
		case .comment:
			return .comment
			
		case .number:
			return .number
			
		case .identifier:
			return .identifier
			
		case .squareBracketOpen:
			return .plain
			
		case .squareBracketClose:
			return .plain
			
		case .editorPlaceholder(_):
			return .editorPlaceholder
			
		}
		
	}
	
}

public struct SavannaCubToken: SavannaKit.Token {
	
	public let cubToken: Cub.Token
	public let range: Range<String.Index>?
	
	public init(cubToken: Cub.Token, in source: String) {
		self.cubToken = cubToken
		
		if let range = cubToken.range {
			let lowerBound = source.index(source.startIndex, offsetBy: range.lowerBound)
			let upperBound = source.index(source.startIndex, offsetBy: range.upperBound)
			
			self.range = lowerBound..<upperBound
			
		} else {
			self.range = nil
		}
		
	}
	
	public var savannaTokenType: SavannaKit.TokenType {
		return cubToken.type
	}
	
}

extension Cub.Lexer: SavannaKit.Lexer {
	
	public func lexerForInput(_ input: String) -> SavannaKit.Lexer {
		return Cub.Lexer(input: input)
	}
	
	public func getSavannaTokens() -> [SavannaKit.Token] {
		return self.tokenize().map({ SavannaCubToken(cubToken: $0, in: input) })
	}
	
}

#endif
