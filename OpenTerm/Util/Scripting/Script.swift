//
//  Script.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/29/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

private let scriptsDir = DocumentManager.shared.activeDocumentsFolderURL.appendingPathComponent(".scripts")

private enum ScriptError: LocalizedError {
    case missingArguments(arguments: [String])

    var errorDescription: String? {
        switch self {
        case .missingArguments(let arguments): return "Script is missing arguments: \(arguments.joined(separator: ", "))"
        }
    }
}

/// This class contains methods for loading/parsing/executing scripts.
/// A script is a text file in the .scripts folder, referenced by a unique name (it's file name).
/// Each script can have a set of named arguments, which are stored in the file in the following format: $<<argument_name>>
class Script {
	let name: String
	var value: String {
		didSet { save() }
	}

	private init(name: String, value: String) {
		self.name = name; self.value = value
	}

	/// Commands to run, in order.
	private var commands: [String] { return value.components(separatedBy: .newlines) }

	/// Replace argument templates with argument values
	func runnableCommands(withArgs args: [String]) throws -> [String] {
        // Step 1: Parse arguments from "--argname=value" to dictionary ["argname": "value"]
        let argDict: [String: String] = Dictionary(uniqueKeysWithValues: args.flatMap({ arg in
            let components = arg.components(separatedBy: "=")
            guard let name = components.first, let value = components.last else { return nil }
            return (name.replacingOccurrences(of: "--", with: ""), value)
        }))

        // Step 2: Find missing arguments, if any
        let providedArgNames = Set(argDict.keys)
        let requiredArgNames = Set(self.argumentNames)
        let missingArgs = requiredArgNames.subtracting(providedArgNames)
        if !missingArgs.isEmpty {
            throw ScriptError.missingArguments(arguments: missingArgs.sorted())
        }

        // Step 3: Replace arg format strings with values for each command, return updated commands.
        return commands.map { command in
            var command = command
            for (key, value) in argDict {
                command = command.replacingOccurrences(of: "$<<\(key)>>", with: value)
            }
            return command
        }
	}

	/// The names of the arguments, unique, and sorted by name
	var argumentNames: [String] {
		let matches = Script.argumentRegex.matches(in: value, options: [], range: NSRange(location: 0, length: value.count))
		return Set(matches.flatMap { result in
			let match = result.range(at: 1)
			if let range = Range(match, in: value) {
				return String(value[range])
			}
			return nil
		}).sorted()
	}

	/// Save the contents of the script to disk
	private func save() {
		do {
			if !DocumentManager.shared.fileManager.fileExists(atPath: scriptsDir.path) {
				try DocumentManager.shared.fileManager.createDirectory(at: scriptsDir, withIntermediateDirectories: true, attributes: nil)
			}
			let scriptFile = scriptsDir.appendingPathComponent(name)
			try value.write(to: scriptFile, atomically: true, encoding: .utf8)
		} catch {
			print("Unable to save script. \(error.localizedDescription)")
		}
	}

	static let argumentRegex = try! NSRegularExpression(pattern: "\\$<<(\\w+)>>", options: [])

	/// Load the script with the given name from disk.
	static func named(_ name: String) throws -> Script {
		let scriptFile = scriptsDir.appendingPathComponent(name)
		let value = try String(contentsOf: scriptFile)
		return Script(name: name, value: value)
	}

	/// Get all of the script names
	static var allNames: [String] {
		return (try? DocumentManager.shared.fileManager.contentsOfDirectory(atPath: scriptsDir.path)) ?? []
	}

    // Create a new script, or overwrite an existing one.
    @discardableResult
    static func create(_ name: String) -> Script {
        let script = Script(name: name, value: "")
        script.save()
        return script
    }
}
