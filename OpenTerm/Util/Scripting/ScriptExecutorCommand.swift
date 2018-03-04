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

	let script: Script
	let arguments: [String]
	let context: CommandExecutionContext
	
	init(script: Script, arguments: [String], context: CommandExecutionContext) {
		self.script = script
		self.arguments = arguments
		self.context = context
	}

	func run(forExecutor executor: CommandExecutor) throws -> ReturnCode {

		guard let tabViewContainer = UIApplication.shared.keyWindow?.rootViewController as? TabViewContainerViewController<TerminalTabViewController> else {
			return 1
		}
		
		guard let activeVC = tabViewContainer.primaryTabViewController.visibleViewController as? TerminalViewController else {
			return 1
		}
		
		let terminalView = activeVC.terminalView

		
		let runner = Runner.runner(for: terminalView)
		
		let source = script.value
		
		var returnCode: Int32 = 0

		do {
			
			try runner.run(source)
			
		} catch {
			
			terminalView.stderrParser.delegate = terminalView
			terminalView.stdoutParser.delegate = terminalView
			
			terminalView.executor.delegate = terminalView
			
			if let error = error as? DisplayableError {
				
				terminalView.writeOutput("Error occurred: \(error.description(inSource: source))")
				
			} else {
				
				terminalView.writeOutput("Unknown error occured")
				
			}
			
			returnCode = 1
		}

		return returnCode
	}
}
