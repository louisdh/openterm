//
//  TerminalView+AutoComplete.swift
//  OpenTerm
//
//  Created by Ian McDowell on 1/28/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import InputAssistant
import ios_system

/// Separates commands into different types.
/// This allows categorization in different ways.
struct CommandTypes: OptionSet {
	let rawValue: Int

	static let affectsFiles    = CommandTypes(rawValue: 1 << 0)
	static let affectsFolders  = CommandTypes(rawValue: 1 << 1)

	/// Get the types of the given command name.
	/// If the command is unknown, it defaults to .affectsFiles.
	static func forCommand(_ command: String) -> CommandTypes {
		switch command {
		case "cd", "ls", "rmdir": return [.affectsFolders]
		case "compress", "cp", "curl", "gunzip", "gzip", "link", "ln", "mv", "rm", "scp", "sftp", "tar", "uncompress": return [.affectsFiles, .affectsFolders]
		case "du", "env", "mkdir", "printenv", "pwd", "setenv", "ssh", "tr", "uname", "unsetenv", "uptime", "whoami", "help", "clear": return []
		default: return [.affectsFiles]
		}
	}
}

/// This extension adds methods to deal with auto completion.
extension TerminalView {

	/// Set up the auto complete functionality.
	func setupAutoComplete() {

		// Set up auto complete manager
		self.autoCompleteManager.dataSource = self
		self.autoCompleteManager.delegate = self.inputAssistantView

		// Set up input assistant and text view for auto completion
		self.inputAssistantView.delegate = self
		self.inputAssistantView.dataSource = self.autoCompleteManager
		self.textView.inputAccessoryView = self.inputAssistantView

		inputAssistantView.trailingActions = [
			InputAssistantAction(image: TerminalView.downArrow, target: self, action: #selector(downTapped))
		]

		self.inputAssistantView.attach(to: self.textView)

		NotificationCenter.default.addObserver(self, selector: #selector(historyDidChange), name: .historyDidChange, object: nil)
	}

	/// Updates auto complete when current command changes
	func updateAutoComplete() {
		switch executor.state {
		case .running:
			autoCompleteManager.commandState = .running
		case .idle:
			autoCompleteManager.commandState = .typing(command: self.currentCommand)
		}
	}

	func insertCompletion(_ completion: AutoCompleteManager.Completion) {
		switch autoCompleteManager.state {
		case .executing:
			guard let character = completion.data as? String else {
				return
			}
			
			textView.insertText(character)
			executor.sendInput(character)
		default:
			// Two options:
			// - There is a space at the end => insert full word
			// - Complete current word

			let currentCommand = self.currentCommand
			if currentCommand.hasSuffix(" ") || currentCommand.hasSuffix("/") {
				// This will be a new argument, or append to the end of a path. Just insert the text.
				textView.insertText(completion.name)
			} else {
				// We need to complete the current argument
				var components = currentCommand.components(separatedBy: CharacterSet.whitespaces)
				if let lastComponent = components.popLast() {
					// If the argument we are completing is a path, we must only replace the last part of the path
					if lastComponent.contains("/") {
						components.append(((lastComponent as NSString).deletingLastPathComponent as NSString).appendingPathComponent(completion.name))
					} else {
						components.append(completion.name)
					}
				}
				self.currentCommand = components.joined(separator: " ")
			}

			// Insert suffix at end
			textView.insertText(completion.appendingSuffix)
		}
	}

	/// Dismiss the keyboard when the down arrow is tapped
	@objc private func downTapped() {
		textView.resignFirstResponder()
	}

	@objc private func historyDidChange() {
		autoCompleteManager.reloadData()
	}

	/// Construct an image for the down arrow.
	private static var downArrow: UIImage {
		return UIGraphicsImageRenderer(size: .init(width: 24, height: 24)).image(actions: { context in

			let path = UIBezierPath()
			path.move(to: CGPoint(x: 1, y: 7))
			path.addLine(to: CGPoint(x: 11, y: 17))
			path.addLine(to: CGPoint(x: 22, y: 7))
			
			UIColor.white.setStroke()
			path.lineWidth = 2
			path.stroke()
			
			context.cgContext.addPath(path.cgPath)
			
		}).withRenderingMode(.alwaysOriginal)
	}
}

extension TerminalView: AutoCompleteManagerDataSource {

	func allCommandsForAutoCompletion() -> [String] {
		let allCommands = (commandsAsArray() as? [String] ?? []).sorted()
		let recentHistory = uniqueItemsInRecentHistory()
		return recentHistory + Script.allNames + allCommands + ["help", "clear"]
	}

	func completionsForProgram(_ command: String, _ currentArguments: [String]) -> [AutoCompleteManager.Completion] {
		// If command is a script, return the argument names in options form, for that script. Without ones that are already entered.
		if Script.allNames.contains(command), let script = try? Script.named(command) {
			return script.argumentNames.map { "--\($0)=" }.map { AutoCompleteManager.Completion($0, appendingSuffix: "") }
		}

		var completions: [AutoCompleteManager.Completion] = []

		// Find types of command, and add files/folders in directory
		// depending on if the command can touch those things.
		let commandTypes = CommandTypes.forCommand(command)

		let currentURL = executor.currentWorkingDirectory
		if let last = currentArguments.last, !last.isEmpty {
			// If we are in the middle of typing an argument, typically there are no completions available.
			// However, if that argument being typed is a path, we should show the contents of the deepest folder in the path.

			// Append the argument to the current url
			var appendedURL = currentURL.appendingPathComponent(last)

			// If it ends with "/", assume it's a folder. Otherwise, we want to look in the parent of whatever is typed.
			if !last.hasSuffix("/") {
				appendedURL.deleteLastPathComponent()
			}

			// If this is a valid path to a folder, then show the contents as completions
			if (try? appendedURL.checkResourceIsReachable()) ?? false {
				// The last argument is a valid path.
				completions += fileSystemCompletions(inDirectory: appendedURL, showFolders: commandTypes.contains(.affectsFolders), showFiles: commandTypes.contains(.affectsFiles))
			}
		} else {
			// No last arguments, so show items in current folder
			completions += fileSystemCompletions(inDirectory: currentURL, showFolders: commandTypes.contains(.affectsFolders), showFiles: commandTypes.contains(.affectsFiles))
		}

		// TODO: There must be a better way to add flags. Don't want to hard code these per command. Parsing man pages could automate this.
		let flags: [String]
		switch command {
		case "awk":
			flags = ["-F", "-v", "-f", "'{", "}'"]
		case "cat":
			flags = ["-b", "-e", "-n", "-s", "-t", "-u", "-v"]
		case "ls":
			flags = ["-@", "-1", "-A", "-a", "-B", "-b", "-C", "-c", "-d", "-e", "-F", "-f", "-G", "-g", "-H", "-h", "-i", "-k", "-L", "-l", "-m", "-n", "-O", "-P", "-q", "-R", "-r", "-S", "-s", "-T", "-t", "-u", "-U", "-v", "-W", "-w", "-x"]
		default:
			flags = []
		}
		completions += flags.map { AutoCompleteManager.Completion($0) }

		return completions
	}

	func completionsForExecution() -> [AutoCompleteManager.Completion] {
		return [
			.init("Stop", data: Parser.Code.endOfText.rawValue) // Send an ETX (end of text) signal to the currently executing command
		]
	}

	func availableCompletions(in completions: [AutoCompleteManager.Completion], forArguments arguments: [String]) -> [AutoCompleteManager.Completion] {
		guard let lastArgument = arguments.last else { return completions }

		// If last character was a space, all completions are available
		if lastArgument.isEmpty { return completions }

		// If we're in the middle of typing a path, special filtering rules apply
		if lastArgument.contains("/") {
			// Get the on-disk url of the path being typed
			let appendedURL = executor.currentWorkingDirectory.appendingPathComponent(lastArgument)

			// Find completions that are inside the appendedURL, and who's names are partially typed.
			// Only completions with `data` set to a URL are considered.
			return completions.filter { completion in
				if let url = completion.data as? URL {
					return appendedURL.standardizedFileURL.path.hasPrefix(url.deletingLastPathComponent().standardizedFileURL.path) && (completion.name.hasPrefix(appendedURL.lastPathComponent) || lastArgument.hasSuffix("/"))
				}
				return false
			}
		}

		// In all other cases, the completion must be partially typed
		return completions.filter { $0.name.hasPrefix(lastArgument) }
	}

	private func uniqueItemsInRecentHistory() -> [String] {
		let recents = Array(HistoryManager.history.prefix(4))
		var seen = Set<String>()
		return recents.filter { recent in
			if seen.contains(recent) {
				return false
			}
			seen.insert(recent)
			return true
		}
	}

	// Get the names of files/folders in the current working directory.
	private func fileSystemCompletions(inDirectory directory: URL, showFolders: Bool, showFiles: Bool) -> [AutoCompleteManager.Completion] {
		if !showFolders && !showFiles { return [] }

		do {
			let contents = try DocumentManager.shared.fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey], options: [])
			return try contents.flatMap { url in
				let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
				let isDirectory = resourceValues.isDirectory ?? false
				if showFolders && isDirectory || showFiles && !isDirectory {
					return AutoCompleteManager.Completion(url.lastPathComponent, appendingSuffix: isDirectory ? "/" : " ", data: url.standardizedFileURL)
				}
				return nil
			}
		} catch {
			return []
		}
	}
}

extension TerminalView: InputAssistantViewDelegate {

	func inputAssistantView(_ inputAssistantView: InputAssistantView, didSelectSuggestionAtIndex index: Int) {
		// Get the text to insert
		let completion = autoCompleteManager.completions[index]

		insertCompletion(completion)
	}
}
