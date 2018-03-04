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
	
	static func runner(for terminalView: TerminalView) -> Runner {
		
		let runner = Runner(logDebug: false, logTime: false)
		
		runner.registerExternalFunction(name: "print", argumentNames: ["input"], returns: true) { (arguments, callback) in
			
			for (_, arg) in arguments {
				
				var input = arg.description(with: runner.compiler)
				input = input.replacingOccurrences(of: "\\n", with: "\n")
				
				terminalView.performOnMain {
					terminalView.appendText(input)
				}
				
			}
			
			Thread.sleep(forTimeInterval: 0.02)
			_ = callback(.number(1))
			return
		}
		
		runner.registerExternalFunction(name: "readNumber", argumentNames: [], returns: true) { (arguments, callback) in
			
			terminalView.didEnterInput = { input in
				if let i = NumberType(input) {
					_ = callback(.number(i))
				} else {
					_ = callback(.number(0))
				}
			}
			
			terminalView.waitForInput()
			
			return
		}
		
		runner.registerExternalFunction(name: "readLine", argumentNames: [], returns: true) { (arguments, callback) in
			
			terminalView.didEnterInput = { input in
				_ = callback(.string(input))
			}
			
			terminalView.waitForInput()
			
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
			
			executorCommand = CubCommandExecutor(commandStr: commandStr, terminalView: terminalView, callback: {
				
				DispatchQueue.main.async {
					
					_ = callback(.number(1))
				}
				
			})
			
		}
		
		runner.executionFinishedCallback = {
			
			DispatchQueue.main.async {
				
				terminalView.stderrParser.delegate = terminalView
				terminalView.stdoutParser.delegate = terminalView
				
				terminalView.executor.delegate = terminalView
				
			}
			
		}
		
		return runner
	}
	
}
