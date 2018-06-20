//
//  AutoCompleteManager.swift
//  OpenTerm
//
//  Created by Ian McDowell on 1/28/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

/// Receive notifications when the auto completion state changes
protocol AutoCompleteManagerDelegate: class {
	func autoCompleteManagerDidChangeState()
	func autoCompleteManagerDidChangeCompletions()
}

/// Provide commands to the completion manager
protocol AutoCompleteManagerDataSource: class {
	func allCommandsForAutoCompletion() -> [String]
	func completionsForProgram(_ command: String, _ currentArguments: [String]) -> [AutoCompleteManager.Completion]
	func availableCompletions(in completions: [AutoCompleteManager.Completion], forArguments arguments: [String]) -> [AutoCompleteManager.Completion]
	func completionsForExecution() -> [AutoCompleteManager.Completion]
}

/// Class that takes the current command and parses it into various states of auto completion,
/// each state with various commands that can be run.
class AutoCompleteManager {

	struct Completion {
		/// Display name for the completion
		let name: String

		/// By default, a whitespace character will be inserted after the completion.
		let appendingSuffix: String

		/// Additional information to store in the completion
		let data: Any?

		init(_ name: String, data: Any? = nil) {
			self.init(name, appendingSuffix: " ", data: data)
		}
		init(_ name: String, appendingSuffix: String, data: Any? = nil) {
			self.name = name; self.appendingSuffix = appendingSuffix; self.data = data
		}
	}

	/// Various states that an auto complete manager can be in
	enum State {

		/// The user has not entered a command yet. All commands are displayed.
		case empty(commands: [String])

		/// The user has entered a command. A series of options are displayed.
		case command(program: String, arguments: [String], completions: [Completion])

		/// There is a command being executed
		case executing(completions: [Completion])
	}

	enum CommandState {
		case typing(command: String)
		case running
	}

	/// The current state, based on the current command.
	private(set) var state: State {
		didSet {
			delegate?.autoCompleteManagerDidChangeState()
		}
	}
	var commandState: CommandState {
		didSet {
			switch commandState {
			case .typing(let command):
				self.currentCommand = command
			case .running:
				self.state = .executing(completions: dataSource?.completionsForExecution() ?? [])
				self.updateCompletions()
			}
		}
	}

	/// The current command text entered by the user.
	private var currentCommand: String = "" {
		didSet {
			guard let dataSource = self.dataSource else {
				return
			}

			// Change the state if needed.
			let components = currentCommand.components(separatedBy: .whitespaces)
			let program = components.first
			let arguments = Array(components.suffix(from: 1))

			switch self.state {
			case .empty:
				// If we're currently in an empty state, and find that a command + " " has been entered, enter the command state.
				if let program = program, components.count > 1 {
					self.state = .command(program: program, arguments: arguments, completions: dataSource.completionsForProgram(program, arguments))
				}
			case .command(let currentProgram, let currentArguments, _):
				if let program = program, program == currentProgram {
					if arguments != currentArguments {
						self.state = .command(program: program, arguments: arguments, completions: dataSource.completionsForProgram(program, arguments))
					}
				} else {
					// No program anymore, go back to empty state
					self.state = .empty(commands: dataSource.allCommandsForAutoCompletion())
				}
			case .executing:
				// If we got a new command, then we left the executing state.
				self.state = .empty(commands: dataSource.allCommandsForAutoCompletion())
			}

			// Update the completions list, since the text changed.
			self.updateCompletions()
		}
	}

	/// A set of completions to be displayed to the user. Updated when the `currentCommand` changes.
	private(set) var completions: [Completion] = [] {
		didSet {
			self.delegate?.autoCompleteManagerDidChangeCompletions()
		}
	}

	/// Set this to receive notifications when state changes.
	weak var delegate: AutoCompleteManagerDelegate?

	/// Set this to provide completions.
	weak var dataSource: AutoCompleteManagerDataSource? {
		didSet {
			self.reloadData()
		}
	}

	/// Create a new auto complete manager. Starts in an empty state.
	init() {
		self.state = .empty(commands: [])
		self.commandState = .typing(command: "")
	}

	/// Reload state & completions from the data source.
	func reloadData() {
		// Update state based on information from data source.
		if let dataSource = dataSource {
			switch self.state {
			case .empty:
				self.state = .empty(commands: dataSource.allCommandsForAutoCompletion())
			case .command(let program, let arguments, _):
				self.state = .command(program: program, arguments: arguments, completions: dataSource.completionsForProgram(program, arguments))
			case .executing:
				self.state = .executing(completions: dataSource.completionsForExecution())
			}
		} else {
			self.state = .empty(commands: [])
		}

		self.updateCompletions()
	}

	/// Update the value of the `completions` property, based on the current command and state.
	private func updateCompletions() {
		switch state {
		case .empty(let completions):
			self.completions = completions.filter { $0 != currentCommand && $0.hasPrefix(currentCommand) }.map { Completion($0) }
		case .command(_, let currentArguments, let completions):
			self.completions = dataSource?.availableCompletions(in: completions, forArguments: currentArguments) ?? []
		case .executing(let completions):
			self.completions = completions
		}
	}
}
