//
//  InterpreterError.swift
//  Cub
//
//  Created by Louis D'hauwe on 15/12/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

/// Interpreter Error
public enum InterpreterErrorType: Error {

	/// Unexpected argument
	case unexpectedArgument

	/// Illegal stack operation
	case illegalStackOperation

	/// Invalid register
	case invalidRegister

	/// Stack overflow occured
	case stackOverflow

	/// Underflow occured
	case underflow
	
	/// Array out of bounds
	case arrayOutOfBounds

}

extension InterpreterErrorType {

	func description(atLine line: Int? = nil) -> String {
		
		if let line = line {
			
			switch self {
			case .unexpectedArgument:
				return "An unexpected argument was found on line \(line) during interpretation."
				
			case .illegalStackOperation:
				return "An illegal stack operation was performed on line \(line) during interpretation."
				
			case .invalidRegister:
				return "An invalid register was accessed on line \(line) during interpretation."
				
			case .stackOverflow:
				return "A stack overflow occurred on line \(line) during interpretation."
				
			case .underflow:
				return "An underflow occurred on line \(line) during interpretation."
				
			case .arrayOutOfBounds:
				return "An array was accessed outside its bounds on line \(line) during interpretation."
				
			}
			
		}
		
		switch self {
		case .unexpectedArgument:
			return "An unexpected argument was found during interpretation."
			
		case .illegalStackOperation:
			return "An illegal stack operation was performed during interpretation."
			
		case .invalidRegister:
			return "An invalid register was accessed during interpretation."
			
		case .stackOverflow:
			return "A stack overflow occurred during interpretation."
			
		case .underflow:
			return "An underflow occurred during interpretation."
			
		case .arrayOutOfBounds:
			return "An array was accessed outside its bounds during interpretation."
			
		}
		
	}
	
}

struct InterpreterError: Equatable {
	
	let type: InterpreterErrorType
	let range: Range<Int>?

}

extension InterpreterError: DisplayableError {
	
	public func description(inSource source: String) -> String {

		guard let startIndex = range?.lowerBound else {
			return type.description()
		}
		
		let lineNumber = source.lineNumber(of: startIndex)
		
		return type.description(atLine: lineNumber)
		
	}
	
}
