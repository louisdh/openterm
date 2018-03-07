//
//  CubCommandExecutor.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 04/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

class CubCommandExecutor: CommandExecutorDelegate, ParserDelegate {
	
	let callback: (() -> Void)
	
	let terminalView: TerminalView
	
	init(commandStr: String, terminalView: TerminalView, callback: @escaping (() -> Void)) {
		
		self.callback = callback
		self.terminalView = terminalView
		
		terminalView.stderrParser.delegate = self
		terminalView.stdoutParser.delegate = self
		
		terminalView.executor.delegate = self
		
		terminalView.executor.dispatch(commandStr)
	}
	
	func commandExecutor(_ commandExecutor: CommandExecutor, receivedStdout stdout: Data) {
		terminalView.stdoutParser.parse(stdout)
	}
	
	func commandExecutor(_ commandExecutor: CommandExecutor, receivedStderr stderr: Data) {
		terminalView.stderrParser.parse(stderr)
	}
	
	func commandExecutor(_ commandExecutor: CommandExecutor, didChangeWorkingDirectory to: URL) {
		
	}
	
	func commandExecutor(_ commandExecutor: CommandExecutor, stateDidChange newState: CommandExecutor.State) {
		
	}
	
	func parser(_ parser: Parser, didReceiveString string: NSAttributedString) {
		
		terminalView.performOnMain {
			self.terminalView.appendText(string)
		}
		
	}
	
	func parserDidEndTransmission(_ parser: Parser) {
		
		terminalView.performOnMain {
			
			self.terminalView.stderrParser.delegate = self.terminalView
			self.terminalView.stdoutParser.delegate = self.terminalView
			
			self.terminalView.executor.delegate = self.terminalView
			
			self.callback()
			
		}
		
	}
	
}
