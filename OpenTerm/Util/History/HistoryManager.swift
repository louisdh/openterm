//
//  HistoryManager.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/30/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

class HistoryManager {

	/// List of commands run. Latest is first.
	private(set) static var history: [String] = loadHistory() {
		didSet {
			NotificationCenter.default.post(name: .historyDidChange, object: nil)
		}
	}

	/// Add the command that the user ran to the history.
	static func add(_ command: String) {
		let command = command.trimmingCharacters(in: .whitespacesAndNewlines)
		if command.isEmpty { return }
		do {
			if !DocumentManager.shared.fileManager.fileExists(atPath: historyFileURL.path) {
				try command.write(to: historyFileURL, atomically: true, encoding: .utf8)
			} else {
				let fileHandle = try FileHandle(forWritingTo: historyFileURL)
				if let value = (command + "\n").data(using: .utf8) {
					fileHandle.write(value)
				}
			}
			history.insert(command, at: 0)
		} catch {
			assertionFailure("Unable to add to history.")
		}
	}

	private static let historyFileURL = DocumentManager.shared.activeDocumentsFolderURL.appendingPathComponent(".history")
	private static func loadHistory() -> [String] {
		do {
			let string = try String(contentsOf: historyFileURL)
			return string.components(separatedBy: .newlines).filter { !$0.isEmpty }.reversed()
		} catch {
			return []
		}
	}
}
