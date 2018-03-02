//
//  StdLib.swift
//  Cub
//
//  Created by Louis D'hauwe on 11/12/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public class StdLib {

	private let sources = ["Arithmetic", "Graphics"]

	public init() {

	}

	public func stdLibCode() throws -> String {

		var stdLib = ""

		#if SWIFT_PACKAGE
			
			// Swift packages don't currently have a resources folder
			
			var url = URL(fileURLWithPath: #file)
			url.deleteLastPathComponent()
			url.appendPathComponent("Sources")
			
			let resourcesPath = url.path
			
		#else
			
			let bundle = Bundle(for: type(of: self))

			guard let resourcesPath = bundle.resourcePath else {
				throw StdLibError.resourceNotFound
			}
			
		#endif
		
		for sourceName in sources {

			let resourcePath = "\(resourcesPath)/\(sourceName).cub"

			let source = try String(contentsOfFile: resourcePath, encoding: .utf8)
			stdLib += source

		}
		
		return stdLib
	}
	
	func registerExternalFunctions(_ runner: Runner) {
		
		// Can't support the format command on Linux at the moment,
		// since String does not conform to CVarArg.
		#if !os(Linux)

		runner.registerExternalFunction(name: "format", argumentNames: ["input", "arg"], returns: true) { (arguments, callback) in
			
			var arguments = arguments
			
			guard let input = arguments.removeValue(forKey: "input") else {
				_ = callback(.string(""))
				return
			}
			
			guard case let .string(inputStr) = input else {
				_ = callback(.string(""))
				return
			}
			
			let otherValues = arguments.values
			
			var varArgs = [CVarArg]()
			
			for value in otherValues {
				
				switch value {
				case .bool:
					break
				case .number(let n):
					varArgs.append(n)
				case .string(let str):
					varArgs.append(str)
				case .struct:
					break
				case .array:
					break
				}
				
			}
			
			let output = String(format: inputStr, arguments: varArgs)
			
			_ = callback(.string(output))
			return
		}
	
		#endif

	}

	enum StdLibError: Error {
		case resourceNotFound
	}

}
