//
//  ScriptExecutorCommand.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/30/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import Cub
import UIKit
import TabView

/// Implementation for running a script.
class ScriptExecutorCommand: CommandExecutorCommand {

	let script: PridelandDocument
	let arguments: [String]
	let context: CommandExecutionContext
	
	init(script: PridelandDocument, arguments: [String], context: CommandExecutionContext) {
		self.script = script
		self.arguments = arguments
		self.context = context
	}

	func run(forExecutor executor: CommandExecutor) throws -> ReturnCode {

		guard let executorDelegate = executor.delegate else {
			return 1
		}
		
		let runner = Runner.runner(executor: executor, executorDelegate: executorDelegate, parametersCallback: {
			
			var parameters = [ValueType]()
			
			for arg in self.arguments {
				// TODO: parse numbers here?
				parameters.append(.string(arg))
			}
			
			return .array(parameters)
		})
		
		let source = script.text
		
		var returnCode: Int32 = 0

		do {
			
			try runner.run(source)
			
		} catch {
			
			let errorMessage: String
			
			if let error = error as? DisplayableError {
				
				// TODO: make error red in output?
//				errorMessage = "\n\u{1B}[1m\u{1B}[31mlab\u{1B}[39;49m\u{1B}[0m"
				
				errorMessage = "\nError occurred: \(error.description(inSource: source))"

			} else {
				
				errorMessage = "\nUnknown error occurred"
				
			}
			
			if let data = errorMessage.data(using: .utf8) {
				executorDelegate.commandExecutor(executor, receivedStderr: data)
			}
			
			returnCode = 1
		}

		return returnCode
	}
}
