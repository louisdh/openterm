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

		runner.registerExternalFunction(name: "dateByAdding", argumentNames: ["value", "unit", "date"], returns: true) { (arguments, callback) in
			
			guard case let .number(value)? = arguments["value"],
				case let .string(unit)? = arguments["unit"],
				case let .number(dateString)? = arguments["date"] else {
				_ = callback(.number(0))
				return
			}
			
			let date = Date(timeIntervalSince1970: dateString)

			let intValue = Int(value)
			
			let componentMapping: [String: Calendar.Component] = ["second": .second,
																  "minute": .minute,
																  "hour": .hour,
																  "day": .day,
																  "month": .month,
																  "year": .year]

			guard let component = componentMapping[unit] else {
				_ = callback(.number(0))
				return
			}
			
			guard let newDate = Calendar.current.date(byAdding: component, value: intValue, to: date) else {
				_ = callback(.number(0))
				return
			}
			
			_ = callback(.number(newDate.timeIntervalSince1970))

		}
		
		runner.registerExternalFunction(name: "currentDate", argumentNames: [], returns: true) { (arguments, callback) in
			_ = callback(.number(Date().timeIntervalSince1970))
		}
		
		runner.registerExternalFunction(name: "dateFromFormat", argumentNames: ["dateString", "format"], returns: true) { (arguments, callback) in
			
			guard case let .string(dateString)? = arguments["dateString"], case let .string(format)? = arguments["format"] else {
				_ = callback(.number(0))
				return
			}
			
			let formatter = DateFormatter()
			formatter.dateFormat = format
			
			if let timeInterval = formatter.date(from: dateString)?.timeIntervalSince1970 {
				_ = callback(.number(timeInterval))
			} else {
				_ = callback(.number(0))
			}
			
		}
		
		runner.registerExternalFunction(name: "formattedDate", argumentNames: ["date", "format"], returns: true) { (arguments, callback) in

			guard case let .number(timeInterval)? = arguments["date"], case let .string(format)? = arguments["format"] else {
				_ = callback(.number(0))
				return
			}
			
			let formatter = DateFormatter()
			formatter.dateFormat = format
			
			let date = Date(timeIntervalSince1970: timeInterval)
			
			_ = callback(.string(formatter.string(from: date)))
			
		}
		
		// Can't support the randomNumber command on Linux at the moment,
		// since arc4random_uniform is not available.
		#if !os(Linux)
		
		runner.registerExternalFunction(name: "randomNumber", argumentNames: ["min", "max"], returns: true) { (arguments, callback) in
			
			func randomInt(min: Int, max: Int) -> Int {
				return min + Int(arc4random_uniform(UInt32(max - min + 1)))
			}
			
			guard case let .number(min)? = arguments["min"], case let .number(max)? = arguments["max"] else {
				let randomNumber = NumberType(arc4random_uniform(1))
				
				_ = callback(.number(randomNumber))
				return
			}
			
			_ = callback(.number(NumberType(randomInt(min: Int(min), max: Int(max)))))
			
		}
		
		#endif

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
