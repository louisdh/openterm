//
//  Cub.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 03/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import Cub
import ios_system
import TabView

var executorCommand: CubCommandExecutor?

public func cub(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {

	let tabViewContainer = UIApplication.shared.keyWindow?.rootViewController as! TabViewContainerViewController<TerminalTabViewController>

	guard let activeVC = tabViewContainer.primaryTabViewController.visibleViewController as? TerminalViewController else {
		return 0
	}

	let terminalView = activeVC.terminalView

	guard argc == 2 else {
		fputs("Usage: cub script.cub\n", thread_stderr)
		return 1
	}

	guard let fileName = argv?[1] else {
		fputs("Usage: cub script.cub\n", thread_stderr)
		return 1
	}

	let path = String(cString: fileName)

	guard FileManager.default.fileExists(atPath: path) else {
		fputs("Missing file \(path)\n", thread_stderr)
		return 1
	}

	let url = URL(fileURLWithPath: path)

	guard let data = FileManager.default.contents(atPath: url.path) else {
		fputs("Missing file \(path)\n", thread_stderr)
		return 1
	}

	guard let source = String.init(data: data, encoding: .utf8) else {
		fputs("Missing file \(path)\n", thread_stderr)
		return 1
	}

	let runner = Runner(logDebug: false, logTime: false)

	runner.registerExternalFunction(name: "print", argumentNames: ["input"], returns: true) { (arguments, callback) in

		for (_, arg) in arguments {
			
			switch arg {
			case .string(let str):
				terminalView.performOnMain {
					terminalView.appendText(str)
				}
			default:
				break
			}
			
		}

		Thread.sleep(forTimeInterval: 0.02)
		_ = callback(.number(1))
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

	do {

		runner.executionFinishedCallback = {

			DispatchQueue.main.async {
				
				terminalView.stderrParser.delegate = terminalView
				terminalView.stdoutParser.delegate = terminalView
				
				terminalView.executor.delegate = terminalView
				
			}

		}
			
		try runner.run(source)

	} catch {
		return 1
	}

	return 0
}

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

			self.terminalView.stderrParser.delegate = nil
			self.terminalView.stdoutParser.delegate = nil
			
			self.terminalView.executor.delegate = nil
			
			self.callback()
			
		}
		
	}
	
}
