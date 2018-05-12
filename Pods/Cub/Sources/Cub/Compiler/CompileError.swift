//
//  CompileError.swift
//  Cub
//
//  Created by Louis D'hauwe on 04/11/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public enum CompileErrorType {
	case unexpectedCommand
	case emptyStruct
	case unexpectedBinaryOperator
	case functionNotFound(String)
	case unbalancedScope
	case variableNotFound(String)
	case incorrectNumberOfArgumentsToFunction(functionName: String, expected: Int, actual: Int)
	case assignmentAsCondition
}

extension CompileErrorType {
	
	func description(atLine line: Int? = nil) -> String {
		
		if let line = line {
			return "Error on line \(line): \(description())"
		} else {
			return description()
		}
		
	}
			
	func description() -> String {

		switch self {
		case .unexpectedCommand:
			return "Found an unexpected command while compiling."
			
		case .emptyStruct:
			return "Structs may not be empty."
			
		case .unexpectedBinaryOperator:
			return "Found an unexpected binary operation."
			
		case .functionNotFound(let name):
			return "Function \"\(name)\" not found."
			
		case .unbalancedScope:
			return "Unbalanced scope."
			
		case .variableNotFound(let name):
			return "Variable \"\(name)\" not found."

		case .incorrectNumberOfArgumentsToFunction(let functionName, let expected, let actual):
			return "The function \"\(functionName)\" expects \(expected) argument(s), not \(actual)."
			
		case .assignmentAsCondition:
			return "A condition is performed using \"==\", not \"=\"."
			
		}
		
	}
	
}

struct CompileError: Error {
	
	let type: CompileErrorType
	
	/// The range in the original source code where the error occurred.
	let range: Range<Int>?
	
}

extension CompileError: DisplayableError {

	public func description(inSource source: String) -> String {
		
		guard let startIndex = range?.lowerBound else {
			return type.description()
		}
		
		let lineNumber = source.lineNumber(of: startIndex)
		
		return type.description(atLine: lineNumber)
		
	}

}
