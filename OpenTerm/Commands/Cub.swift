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

@_cdecl("cub")
public func cub(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {

	guard let args = convertCArguments(argc: argc, argv: argv) else {
		return 1
	}
	
	guard let tabViewContainer = UIApplication.shared.keyWindow?.rootViewController as? TabViewContainerViewController<TerminalTabViewController> else {
		return 1
	}

	guard let activeVC = tabViewContainer.primaryTabViewController.visibleViewController as? TerminalViewController else {
		return 1
	}

	let terminalView = activeVC.terminalView

	let usage = "Usage: cub script.cub\n"
	
	guard argc == 2 else {
		fputs(usage, thread_stderr)
		return 1
	}

	guard let fileName = argv?[1] else {
		fputs(usage, thread_stderr)
		return 1
	}

	let path = String(cString: fileName)

	let url = URL(fileURLWithPath: path)

	guard let data = FileManager.default.contents(atPath: url.path) else {
		fputs("Missing file \"\(path)\"\n", thread_stderr)
		return 1
	}

	guard let source = String(data: data, encoding: .utf8) else {
		fputs("Missing file \"\(path)\"\n", thread_stderr)
		return 1
	}

	let runner = Runner.runner(executor: terminalView.executor, executorDelegate: terminalView, parametersCallback: {
		
		var parameters = [ValueType]()
		
		for arg in args {
			// TODO: parse numbers here?
			parameters.append(.string(arg))
		}
		
		return .array(parameters)
	})

	do {

		try runner.run(source)

	} catch {

		terminalView.stderrParser.delegate = terminalView
		terminalView.stdoutParser.delegate = terminalView

		terminalView.executor.delegate = terminalView

		if let error = error as? DisplayableError {

			terminalView.writeOutput("Error occurred: \(error.description(inSource: source))")

		} else {

			terminalView.writeOutput("Unknown error occurred")

		}

		return 1
	}

	return 0
}
