//
//  RunnerError.swift
//  Cub
//
//  Created by Louis D'hauwe on 26/03/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public enum RunnerError: Error {
	case registerNotFound
	case stdlibFailed
	case runFailed
}

extension RunnerError: DisplayableError {
	
	public func description(inSource source: String) -> String {
		
		switch self {
		case .registerNotFound:
			return "Register not found."
			
		case .stdlibFailed:
			return "An internal error in the standard library occurred."
			
		case .runFailed:
			return "An unknown error occurred."
		}
		
	}
	
}
