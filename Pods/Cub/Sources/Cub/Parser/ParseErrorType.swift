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

}

extension ParseErrorType {
	
	func description(atLine line: Int? = nil) -> String {
		
		if let line = line {
			
			switch self {
			case .unexpectedToken:
				return "Unexpected token on line \(line)"
				
			case .undefinedOperator(let op):
				return "Undefined operator (\"\(op)\") on line \(line)"
				
			case .expectedCharacter(let c):
				return "Expected character \"\(c)\" on line \(line)"
				
			case .expectedCharacterButFound(let c1, let c2):
				return "Expected character \"\(c1)\" but found \"\(c2)\" on line \(line)"
				
			case .expectedExpression:
				return "Expected expression on line \(line)"
				
			case .expectedArgumentList:
				return "Expected argument list on line \(line)"
				
			case .expectedMemberList:
				return "Expected member list on line \(line)"
				
			case .expectedFunctionName:
				return "Expected function name on line \(line)"
				
			case .expectedStructName:
				return "Expected struct name on line \(line)"
				
			case .internalInconsistencyOccurred:
				return "Internal inconsistency occured on line \(line)"
				
			case .illegalBinaryOperation:
				return "Illegal binary operation on line \(line)"
				
			case .illegalStatement:
				return "Illegal statement on line \(line)"
				
			case .expectedVariable:
				return "Expected variable on line \(line)"
				
			case .emptyStructNotAllowed:
				return "Struct with no members found on line \(line), structs may not be empty"
			
			case .invalidAssignmentValue(let value):
				return "Cannot assign \(value) on line \(line)"
				
			}
			
		}
		
		switch self {
		case .unexpectedToken:
			return "Unexpected token"
			
		case .undefinedOperator(let op):
			return "Undefined operator (\"\(op)\")"
			
		case .expectedCharacter(let c):
			return "Expected character \"\(c)\""
			
		case .expectedCharacterButFound(let c1, let c2):
			return "Expected character \"\(c1)\" but found \"\(c2)\""
			
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
		
		case .invalidAssignmentValue:
			return "Invalid assignment value"
		}
	}
}
