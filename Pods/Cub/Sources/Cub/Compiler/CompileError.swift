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
	
}

extension CompileErrorType{
	
	func description(atLine line: Int? = nil) -> String {
		
		if let line = line {
			
			switch self {
			case .unexpectedCommand:
				return "Found an unexpected command on line \(line) while compiling."
				
			case .emptyStruct:
				return "Structs may not be empty. Found an empty struct on line \(line)."
				
			case .unexpectedBinaryOperator:
				return "Found an unexpected binary operation on line \(line)."
				
			case .functionNotFound(let name):
				return "Function \"\(name)\" not found on line \(line)."
				
			case .unbalancedScope:
				return "Unbalanced scope on line \(line)."
				
			}
			
		} else {
			
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
				
			}
			
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
