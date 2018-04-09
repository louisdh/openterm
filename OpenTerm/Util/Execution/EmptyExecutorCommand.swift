//
//  EmptyExecutorCommand.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 09/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import ios_system

/// No-op command to run.
struct EmptyExecutorCommand: CommandExecutorCommand {
	func run(forExecutor executor: CommandExecutor) throws -> ReturnCode {
		return 0
	}
}
