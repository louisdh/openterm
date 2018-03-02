//
//  InterpreterError.swift
//  Cub
//
//  Created by Louis D'hauwe on 15/12/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

/// Interpreter Error
public enum InterpreterError: Error {

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
