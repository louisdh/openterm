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
	case invalidURL

	var errorDescription: String? {
		switch self {
		case .missingArguments(let arguments):
			return "Script is missing arguments: \(arguments.joined(separator: ", "))"
		case .invalidURL:
			return "Invalid url"
		}
	}
}

/// This class contains methods for loading/parsing/executing scripts.
class Script {
	
	/// URL of the script file.
	/// Used for saving.
	let url: URL
	
	let name: String
	
	var value: String {
		didSet {
			save()
		}
	}

	private init(url: URL, name: String, value: String) {
		self.url = url
		self.name = name
		self.value = value
	}

	/// Save the contents of the script to disk
	private func save() {
		do {
			if !DocumentManager.shared.fileManager.fileExists(atPath: scriptsDir.path) {
				try DocumentManager.shared.fileManager.createDirectory(at: scriptsDir, withIntermediateDirectories: true, attributes: nil)
			}
			try value.write(to: url, atomically: true, encoding: .utf8)
		} catch {
			print("Unable to save script. \(error.localizedDescription)")
		}
	}

	/// Load the script with the given name from disk.
	static func named(_ name: String) throws -> Script {
		let scriptURL = scriptsDir.appendingPathComponent(name)
		let value = try String(contentsOf: scriptURL)
		return Script(url: scriptURL, name: name, value: value)
	}

	/// Get all of the script names
	static var allNames: [String] {
		return (try? DocumentManager.shared.fileManager.contentsOfDirectory(atPath: scriptsDir.path)) ?? []
	}

	// Create a new script, or overwrite an existing one.
	@discardableResult
	static func create(_ name: String) -> Script {
		let scriptURL = scriptsDir.appendingPathComponent(name)
		let script = Script(url: scriptURL, name: name, value: "")
		script.save()
		return script
	}
}
