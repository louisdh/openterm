//
//  ParseErrorType.swift
//  Cub
//
//  Created by Louis D'hauwe on 15/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public enum ParseErrorType {
	
	case unexpectedToken
	case undefinedOperator(String)
	
	case expectedCharacter(String)
	case expectedCharacterButFound(char: String, token: Token)
	case expectedExpression
	case expectedArgumentList
	case expectedMemberList
	case expectedFunctionName
	case expectedStructName
	case expectedVariable
	
	case emptyStructNotAllowed
	
	case illegalBinaryOperation
	
	case illegalStatement
	
	case internalInconsistencyOccurred

	case invalidAssignmentValue(value: String)
	
	case editorPlaceholder(placeholder: String)

	case stackOverflow

	case invalidEscapeSequenceInStringLiteral(sequence: String)

	case unterminatedStringLiteral

}

extension ParseErrorType {
	
	func description(atLine line: Int? = nil) -> String {
		
		if let line = line {
			return "Error on line \(line): \(description())"
		} else {
			return description()
		}
		
	}
		
	func description() -> String {
		
		switch self {
		case .unexpectedToken:
			return "Unexpected token"
			
		case .undefinedOperator(let op):
			return "Undefined operator (\"\(op)\")"
			
		case .expectedCharacter(let c):
			return "Expected character \"\(c)\""
			
		case .expectedCharacterButFound(let c1, let c2):
			return "Expected character \"\(c1)\" but found \"\(c2.type)\""
			
		case .expectedExpression:
			return "Expected expression"
			
		case .expectedArgumentList:
			return "Expected argument list"
			
		case .expectedMemberList:
			return "Expected member list"
			
		case .expectedFunctionName:
			return "Expected function name"
			
		case .expectedStructName:
			return "Expected struct name"
			
		case .internalInconsistencyOccurred:
			return "Internal inconsistency occured"
			
		case .illegalBinaryOperation:
			return "Illegal binary operation"
			
		case .illegalStatement:
			return "Illegal statement"
			
		case .expectedVariable:
			return "Expected variable"
			
		case .emptyStructNotAllowed:
			return "Struct with no members found, structs may not be empty"
		
		case .invalidAssignmentValue(let value):
			return "Cannot assign \(value)"
			
		case .editorPlaceholder(let placeholder):
			return "Editor placeholder \"\(placeholder)\" in source file"
			
		case .stackOverflow:
			return "Parser stack overflow"
			
		case .invalidEscapeSequenceInStringLiteral(let sequence):
			return "Invalid escape sequence \"\(sequence)\" in literal"

		case .unterminatedStringLiteral:
			return "Unterminated string literal"
			
		}
	}
}
