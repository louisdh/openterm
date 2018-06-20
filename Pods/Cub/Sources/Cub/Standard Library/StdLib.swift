//
//  StdLib.swift
//  Cub
//
//  Created by Louis D'hauwe on 11/12/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public class StdLib {

	private let sources = ["Arithmetic", "String"]

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
		
		let stringAtRangeDoc = """
							Returns part of a string, given a range.
							- Parameter string: the string to get a part from.
							- Parameter range: the range of the part in the string you want.
							- Returns: the part of the string, for the given range.
							"""
		runner.registerExternalFunction(documentation: stringAtRangeDoc, name: "stringAtRange", argumentNames: ["string", "range"], returns: true) { (arguments, callback) in
			
			guard case let .string(string)? = arguments["string"], case let .struct(rangeData)? = arguments["range"] else {
				_ = callback(.nil)
				return
			}
		
			guard let lowerboundId = runner.compiler.getStructMemberId(for: "lowerbound") else {
				_ = callback(.nil)
				return
			}
			
			guard let upperboundId = runner.compiler.getStructMemberId(for: "upperbound") else {
				_ = callback(.nil)
				return
			}
			
			guard let lowerboundRaw = rangeData.members[lowerboundId], case let .number(lowerbound) = lowerboundRaw else {
				_ = callback(.nil)
				return
			}
			
			guard let upperboundRaw = rangeData.members[upperboundId], case let .number(upperbound) = upperboundRaw else {
				_ = callback(.nil)
				return
			}
			
			guard Int(lowerbound) < Int(upperbound) else {
				_ = callback(.nil)
				return
			}
			
			guard Int(lowerbound) >= 0 else {
				_ = callback(.nil)
				return
			}
			
			guard Int(upperbound) <= string.count else {
				_ = callback(.nil)
				return
			}
			
			let rangeLower = string.index(string.startIndex, offsetBy: Int(lowerbound))
			let rangeUpper = string.index(string.startIndex, offsetBy: Int(upperbound))

			let range = rangeLower..<rangeUpper
			
			_ = callback(.string(String(string[range])))

		}
		
		#if !os(Linux)
		
			let regexDoc = """
							Get an array of ranges for all the matches of a regular expression in a given string.
							- Parameter pattern: the regular expression pattern. Cub uses the same regular expressions as Apple does, more info can be found here: https://developer.apple.com/documentation/foundation/nsregularexpression#1965589.
							- Parameter string: the string to match the regular expression on.
							- Returns: an array of ranges for all the matches of the regular expression in the provided string.
							"""
		
			runner.registerExternalFunction(documentation: regexDoc, name: "regex", argumentNames: ["pattern", "string"], returns: true) { (arguments, callback) in
				
				guard case let .string(pattern)? = arguments["pattern"], case let .string(text)? = arguments["string"] else {
					_ = callback(.nil)
					return
				}

				guard let regEx = try? NSRegularExpression(pattern: pattern, options: []) else {
					_ = callback(.nil)
					return
				}
				
				let matches = regEx.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
				
				let ranges = matches.compactMap({ Range<String.Index>.init($0.range, in: text) })
				
				var cubRanges = [ValueType]()
				
				for range in ranges {
					
					guard let lowerboundId = runner.compiler.getStructMemberId(for: "lowerbound") else {
						continue
					}
					
					guard let upperboundId = runner.compiler.getStructMemberId(for: "upperbound") else {
						continue
					}
					
					let lowerbound = text.distance(from: text.startIndex, to: range.lowerBound)
					let upperbound = text.distance(from: text.startIndex, to: range.upperBound)

					cubRanges.append(.struct(StructData(members: [lowerboundId: .number(NumberType(lowerbound)),
																  upperboundId: .number(NumberType(upperbound))])))
				}
				
				_ = callback(.array(cubRanges))
				
			}
		
		#endif
		
		let isEmptyDoc = """
						Check if a value is empty.
						- Parameter value: the value to check wether it's empty.
						- Returns: true if the value is empty, false otherwise.
						"""
		
		runner.registerExternalFunction(documentation: isEmptyDoc, name: "isEmpty", argumentNames: ["value"], returns: true) { (arguments, callback) in
			
			guard let value = arguments["value"] else {
				_ = callback(.nil)
				return
			}
			
			_ = callback(.bool(value.size == 0))
			
		}
		
		let sizeOfDoc = """
						Get the size of a value.
						For arrays this returns the number of elements in the array.
						For strings this returns the length.
						- Parameter value: the value to get the size of.
						- Returns: size of value.
						"""
		
		runner.registerExternalFunction(documentation: sizeOfDoc, name: "sizeOf", argumentNames: ["value"], returns: true) { (arguments, callback) in
			
			guard let value = arguments["value"] else {
				_ = callback(.nil)
				return
			}
			
			_ = callback(.number(value.size))
			
		}
		
		let splitDoc = """
						Split a string into smaller strings.
						- Parameter string: the string to split.
						- Parameter separator: the separator to split by.
						- Returns: an array of strings.
						"""
		
		runner.registerExternalFunction(documentation: splitDoc, name: "split", argumentNames: ["string", "separator"], returns: true) { (arguments, callback) in
			
			guard case let .string(value)? = arguments["string"], case let .string(separator)? = arguments["separator"] else {
				_ = callback(.nil)
				return
			}
			
			let splitted = value.unescaped.components(separatedBy: separator.unescaped)
			_ = callback(.array(splitted.map({ ValueType.string($0) })))

		}
		
		let exitDoc = """
						Terminate the program.
						"""
		
		runner.registerExternalFunction(documentation: exitDoc, name: "exit", argumentNames: [], returns: true) { (arguments, callback) in
			
			runner.interpreter?.isManuallyTerminated = true
			_ = callback(.nil)
			
		}
		
		let parseNumberDoc = """
						Tries to parse a string to a number.
						- Parameter value: the string to parse.
						- Returns: a number if the string could be parsed, otherwise nil.
						"""
		
		runner.registerExternalFunction(documentation: parseNumberDoc, name: "parseNumber", argumentNames: ["string"], returns: true) { (arguments, callback) in
			
			guard case let .string(value)? = arguments["string"] else {
				_ = callback(.nil)
				return
			}
			
			if let numberValue = NumberType(value) {
				_ = callback(.number(numberValue))
			} else {
				_ = callback(.nil)
			}
				
		}
		
		let isNumberDoc = """
						Checks if the value is a number.
						- Parameter value: the value to check the type of.
						- Returns: true if the value is a number, false otherwise.
						"""
		
		runner.registerExternalFunction(documentation: isNumberDoc, name: "isNumber", argumentNames: ["value"], returns: true) { (arguments, callback) in

			guard let value = arguments["value"] else {
				_ = callback(.bool(false))
				return
			}
			
			_ = callback(.bool(value.isNumber))
			
		}
		
		let isStringDoc = """
						Checks if the value is a string.
						- Parameter value: the value to check the type of.
						- Returns: true if the value is a string, false otherwise.
						"""
		
		runner.registerExternalFunction(documentation: isStringDoc, name: "isString", argumentNames: ["value"], returns: true) { (arguments, callback) in
			
			guard let value = arguments["value"] else {
				_ = callback(.bool(false))
				return
			}
			
			_ = callback(.bool(value.isString))
			
		}
		
		let isBoolDoc = """
						Checks if the value is a boolean.
						- Parameter value: the value to check the type of.
						- Returns: true if the value is a boolean, false otherwise.
						"""
		
		runner.registerExternalFunction(documentation: isBoolDoc, name: "isBool", argumentNames: ["value"], returns: true) { (arguments, callback) in
			
			guard let value = arguments["value"] else {
				_ = callback(.bool(false))
				return
			}
			
			_ = callback(.bool(value.isBool))
			
		}
		
		let isArrayDoc = """
						Checks if the value is an array.
						- Parameter value: the value to check the type of.
						- Returns: true if the value is an array, false otherwise.
						"""
		
		runner.registerExternalFunction(documentation: isArrayDoc, name: "isArray", argumentNames: ["value"], returns: true) { (arguments, callback) in
			
			guard let value = arguments["value"] else {
				_ = callback(.bool(false))
				return
			}
			
			_ = callback(.bool(value.isArray))
			
		}
		
		let isStructDoc = """
						Checks if the value is a struct.
						- Parameter value: the value to check the type of.
						- Returns: true if the value is a struct, false otherwise.
						"""
		
		runner.registerExternalFunction(documentation: isStructDoc, name: "isStruct", argumentNames: ["value"], returns: true) { (arguments, callback) in
			
			guard let value = arguments["value"] else {
				_ = callback(.bool(false))
				return
			}
			
			_ = callback(.bool(value.isStruct))
			
		}
		
		let dateByAddingDoc = """
						Add a specific amount of a date unit to a given date.

						Example:
						myDate = currentDate()
						tomorrowThisTime = dateByAdding(1, "day", myDate)

						- Parameter value: the number that you want to add to the given date, in the given unit.
						- Parameter unit: a string that represents a date unit. One of the following values: "second", "minute", "hour", "day", "month", "year"
						- Parameter date: a number that represents a date.
						- Returns: a number representing the given date, having added the value in the specified unit.
						"""
		
		runner.registerExternalFunction(documentation: dateByAddingDoc, name: "dateByAdding", argumentNames: ["value", "unit", "date"], returns: true) { (arguments, callback) in
			
			guard case let .number(value)? = arguments["value"],
				case let .string(unit)? = arguments["unit"],
				case let .number(dateString)? = arguments["date"] else {
				_ = callback(.nil)
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
				_ = callback(.nil)
				return
			}
			
			guard let newDate = Calendar.current.date(byAdding: component, value: intValue, to: date) else {
				_ = callback(.nil)
				return
			}
			
			_ = callback(.number(newDate.timeIntervalSince1970))

		}
		
		let currentDateDoc = """
							Get the current date and time, represented as a number.
							- Returns: a number representing the current date and time.
							"""
		
		runner.registerExternalFunction(documentation: currentDateDoc, name: "currentDate", argumentNames: [], returns: true) { (arguments, callback) in
			_ = callback(.number(Date().timeIntervalSince1970))
		}
		
		let dateFromFormatDoc = """
							Get a date (represented as a number), from a string in a specified format.

							Example:
							myDate = dateFromFormat("2012-02-20", "yyyy-MM-dd")

							- Parameter dateString: a date in a string format.
							- Parameter format: the format that the given date string is in.
							- Returns: a date.
							"""
		
		runner.registerExternalFunction(documentation: dateFromFormatDoc, name: "dateFromFormat", argumentNames: ["dateString", "format"], returns: true) { (arguments, callback) in
			
			guard case let .string(dateString)? = arguments["dateString"], case let .string(format)? = arguments["format"] else {
				_ = callback(.nil)
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
		
		let formattedDateDoc = """
							Get a formatted date (a string) from a date (represented as a number) in a specified format.

							Example:
							myDate = currentDate()
							myDateString = formattedDate(myDate, "yyyy-MM-dd")

							- Parameter date: a number representing a date.
							- Parameter format: the format to get the date in.
							- Returns: a string of the given date, formatted.
							"""
		
		runner.registerExternalFunction(documentation: formattedDateDoc, name: "formattedDate", argumentNames: ["date", "format"], returns: true) { (arguments, callback) in

			guard case let .number(timeInterval)? = arguments["date"], case let .string(format)? = arguments["format"] else {
				_ = callback(.nil)
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
		
		let randomNumberDoc = """
							Get a random number.

							Example:
							myDiceRoll = randomNumber(1, 6)

							- Parameter min: minimum number.
							- Parameter max: maximum number.
							- Returns: a random number.
							"""
		
		runner.registerExternalFunction(documentation: randomNumberDoc, name: "randomNumber", argumentNames: ["min", "max"], returns: true) { (arguments, callback) in
			
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

		let formatDoc = """
							Get a formatted string with an argument.

							Example:
							formattedNumber = format("%.f", 1.0) // "1"

							- Parameter input: a string template.
							- Parameter arg: the argument to insert in the template.
							- Returns: a formatted string.
							"""
		
		runner.registerExternalFunction(documentation: formatDoc, name: "format", argumentNames: ["input", "arg"], returns: true) { (arguments, callback) in
			
			var arguments = arguments
			
			guard let input = arguments.removeValue(forKey: "input") else {
				_ = callback(.nil)
				return
			}
			
			guard case let .string(inputStr) = input else {
				_ = callback(.nil)
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
				case .nil:
					break
				}
				
			}
			
			let output = String(format: inputStr.unescaped, arguments: varArgs)
			
			_ = callback(.string(output))
			return
		}
	
		#endif

	}

	enum StdLibError: Error {
		case resourceNotFound
	}

}

public extension String {
	
	public var unescaped: String {
		let entities = ["\0", "\t", "\n", "\r", "\"", "\'", "\\"]
		var current = self
		for entity in entities {
			let descriptionCharacters = entity.debugDescription.dropFirst().dropLast()
			let description = String(descriptionCharacters)
			current = current.replacingOccurrences(of: description, with: entity)
		}
		return current
	}
	
}
