//
//  CommandExecutionContext.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/30/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

/// Stores variables and context about the commands in an executor that are running or have run.
struct CommandExecutionContext {

	/// Predefined keys for accessing storage
	enum Key: String {

		/// The exit status of the last command that ran
		case status
	}

	private var storage: [String: String]

	init() {
		storage = [:]
	}

	/// Access storage from predefined keys
	subscript(key: Key) -> String? {
		get {
			return self[key.rawValue]
		}
		set {
			self[key.rawValue] = newValue
		}
	}

	/// Access storage from raw keys.
	subscript(key: String) -> String? {
		get {
			return storage[key]
		}
		set {
			storage[key] = newValue
		}
	}

	/// Replaces occurrences of each $variable in the context with its value.
	func apply(toCommand command: String) -> String {
		var command = command
		for (key, value) in storage {
			let escaped = CommandExecutionContext.escape(string: value)
			command = command.replacingOccurrences(of: "$\(key)", with: escaped)
		}
		return command
	}

	/// Escapes the string for entering into a command
	/// Finds the instances of quote (") and backward slash (\) and prepends
	/// the escape character backward slash (\).
	private static func escape(string: String) -> String {
		func needsEscape(_ char: UInt8) -> Bool {
			return char == UInt8(ascii: "\\") || char == UInt8(ascii: "\"")
		}

		guard let pos = string.utf8.index(where: needsEscape) else {
			return string
		}
		var newString = String(string[..<pos])
		for char in string.utf8[pos...] {
			if needsEscape(char) {
				newString += "\\"
			}
			newString += String(UnicodeScalar(char))
		}

		// Surround in quotes if it has non-alphanumeric characters.
		if newString.isEmpty || newString.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
			return "\"\(newString)\""
		}
		return newString
	}
}
