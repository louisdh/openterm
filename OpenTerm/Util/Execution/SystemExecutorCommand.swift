//
//  SystemExecutorCommand.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 09/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import ios_system

/// Basic implementation of a command, run ios_system
struct SystemExecutorCommand: CommandExecutorCommand {
	
	let command: String
	
	func run(forExecutor executor: CommandExecutor) throws -> ReturnCode {
		
		// ios_system requires these to be set to nil before command execution
		thread_stdout = nil
		thread_stderr = nil
		// Pass the value of the string to system, return its exit code.
		let returnCode = ios_system(command.utf8CString)
		
		// Flush pipes to make sure all data is read
		fflush(stdout)
		fflush(stderr)
		
		return returnCode
	}
}
