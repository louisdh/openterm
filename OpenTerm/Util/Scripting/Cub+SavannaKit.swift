//
//  Cub+SavannaKit.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 04/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import SavannaKit
import Cub

extension Cub.TokenType: SavannaKit.TokenType {

	public var syntaxColorType: SyntaxColorType {

		switch self {
		case .booleanAnd, .booleanNot, .booleanOr:
			return .plain

		case .shortHandAdd, .shortHandDiv, .shortHandMul, .shortHandPow, .shortHandSub:
			return .plain

		case .equals, .notEqual, .dot, .ignoreableToken, .parensOpen, .parensClose, .curlyOpen, .curlyClose, .comma, .squareBracketOpen, .squareBracketClose:
			return .plain

		case .comparatorEqual, .comparatorLessThan, .comparatorGreaterThan, .comparatorLessThanEqual, .comparatorGreaterThanEqual:
			return .plain

		case .other:
			return .plain

		case .break, .continue, .function, .if, .else, .while, .for, .do, .times, .return, .returns, .repeat, .true, .false, .struct, .guard, .in, .nil:
			return .keyword

		case .string:
			return .string

		case .comment:
			return .comment

		case .number:
			return .number

		case .identifier:
			return .identifier

		case .editorPlaceholder:
			return .editorPlaceholder
			
		}

	}

}

extension Cub.Token: SavannaKit.Token {

	public var savannaTokenType: SavannaKit.TokenType {
		return self.type
	}

}

extension Cub.Lexer: SavannaKit.Lexer {

	public func lexerForInput(_ input: String) -> SavannaKit.Lexer {
		return Cub.Lexer(input: input)
	}

	public func getSavannaTokens() -> [SavannaKit.Token] {
		return self.tokenize()
	}

}
