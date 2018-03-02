//
//  TokenType.swift
//  Cub
//
//  Created by Louis D'hauwe on 09/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public enum TokenType {
	
	/// Token which has no effect on program, such as white space
	case ignoreableToken
	case comment
	
	case identifier(String)
	case number(NumberType)
	case string(String)

	case parensOpen
	case parensClose
	case curlyOpen
	case curlyClose
	case squareBracketOpen
	case squareBracketClose
	case comma
	case dot
	
	// Comparators
	case comparatorEqual
	case comparatorGreaterThan
	case comparatorLessThan
	case comparatorGreaterThanEqual
	case comparatorLessThanEqual
	
	case equals
	case notEqual
	
	// Boolean operators
	case booleanAnd
	case booleanOr
	case booleanNot
	
	// Short hand operators
	case shortHandAdd
	case shortHandSub
	case shortHandMul
	case shortHandDiv
	case shortHandPow
	
	// Keywords
	case `while`
	case `for`
	case `if`
	case `else`
	case function
	case `true`
	case `false`
	case `continue`
	case `break`
	case `do`
	case times
	case `repeat`
	case `return`
	case returns
	case `struct`
	case `guard`
	case `in`
	case `nil`

	// Fallback
	case other(String)
	
	var uniqueDescription: String {
		return "\(self)"
	}
	
}

func ==(lhs: TokenType, rhs: TokenType) -> Bool {
	return lhs.uniqueDescription == rhs.uniqueDescription
}
