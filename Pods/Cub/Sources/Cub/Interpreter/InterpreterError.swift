//
//  InterpreterError.swift
//  Cub
//
//  Created by Louis D'hauwe on 15/12/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

/// Interpreter Error
public enum InterpreterErrorType: Error, Equatable {

	/// Unexpected argument
	case unexpectedArgument

	/// Unexpected argument
	case unexpectedArgumentExpectedNumber(found: ValueType)

	/// Unexpected argument
	case unexpectedArgumentExpectedBool

	/// Illegal stack operation
	case illegalStackOperation

	/// Invalid register
	case invalidRegister

	/// Stack overflow occured
	case stackOverflow

	/// Underflow occured
	case underflow
	
	/// Array out of bounds
	case arrayOutOfBounds(index: Int, arraySize: Int)

	/// Out of memory
	case outOfMemory

}

extension InterpreterErrorType {

	func description(atLine line: Int? = nil) -> String {
		
		if let line = line {
			return "Error on line \(line): \(description())"
		} else {
			return description()
		}
		
	}
	
	func description() -> String {
		
		switch self {
		case .unexpectedArgument:
			return "An unexpected argument was found during interpretation."
			
		case .unexpectedArgumentExpectedNumber(let foundValue):
			return "Expected a number during interpretation but found \(foundValue)."
			
		case .unexpectedArgumentExpectedBool:
			return "An unexpected argument was found during interpretation, expected a boolean."
			
		case .illegalStackOperation:
			return "An illegal stack operation was performed during interpretation."
			
		case .invalidRegister:
			return "An invalid register was accessed during interpretation."
			
		case .stackOverflow:
			return "A stack overflow occurred during interpretation."
			
		case .underflow:
			return "An underflow occurred during interpretation."
			
		case .arrayOutOfBounds(let index, let arraySize):
			return "An array was accessed outside its bounds during interpretation, tried to access index \(index) in an array of length \(arraySize)."
			
		case .outOfMemory:
			return "Out of memory."
			
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
