//
//  Cub+Runner.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 04/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import Cub

extension Runner {
	
	static func runner(executor: CommandExecutor, executorDelegate: CommandExecutorDelegate) -> Runner {
		
		let runner = Runner(logDebug: false, logTime: false)
		
		runner.registerExternalFunction(name: "print", argumentNames: ["input"], returns: true) { (arguments, callback) in
			
			for (_, arg) in arguments {
				
				var input = arg.description(with: runner.compiler)
				input = input.replacingOccurrences(of: "\\n", with: "\n")
				
				if let data = input.data(using: .utf8) {
					executorDelegate.commandExecutor(executor, receivedStdout: data)
				}
			}
			
			Thread.sleep(forTimeInterval: 0.02)
			_ = callback(.number(1))
			return
		}
		
		runner.registerExternalFunction(name: "readNumber", argumentNames: [], returns: true) { (arguments, callback) in
			
			executorDelegate.commandExecutor(executor, waitForInput: { (input) in
				
				if let i = NumberType(input) {
					_ = callback(.number(i))
				} else {
					_ = callback(.number(0))
				}
				
			})

			return
		}
		
		runner.registerExternalFunction(name: "readLine", argumentNames: [], returns: true) { (arguments, callback) in
			
			executorDelegate.commandExecutor(executor, waitForInput: { (input) in
				_ = callback(.string(input))
			})

			return
		}
		
		runner.registerExternalFunction(name: "exec", argumentNames: ["command"], returns: true) { (arguments, callback) in
			
			var arguments = arguments
			
			guard let command = arguments.removeValue(forKey: "command") else {
				_ = callback(.number(1))
				return
			}
			
			guard case let .string(commandStr) = command else {
				_ = callback(.number(1))
				return
			}

			executorDelegate.commandExecutor(executor, executeSubCommand: commandStr, callback: {
				
				DispatchQueue.main.async {
					
					_ = callback(.number(1))
				}

			})
			
		}

		return runner
	}
	
}
