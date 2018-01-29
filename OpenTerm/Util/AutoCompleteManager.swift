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
    func optionsForCommand(_ command: String) -> [String]
}

/// Class that takes the current command and parses it into various states of auto completion,
/// each state with various commands that can be run.
class AutoCompleteManager {

    /// Various states that an auto complete manager can be in
    enum State {

        /// The user has not entered a command yet. All commands are displayed.
        case empty(commands: [String])

        /// The user has entered a command. A series of options are displayed.
        case command(command: String, options: [String])
    }

    /// The current state, based on the current command.
    var state: State {
        didSet {
            print("State: \(state)")
            delegate?.autoCompleteManagerDidChangeState()
        }
    }

    /// The current command text entered by the user.
    var currentCommand: String = "" {
        didSet {
            guard let dataSource = self.dataSource else { return }

            // Change the state if needed.
            let components = currentCommand.components(separatedBy: .whitespaces)
            switch self.state {
            case .empty:
                // If we're currently in an empty state, and find that a command + " " has been entered, enter the command state.
                if let command = components.first, components.count > 1 {
                    self.state = .command(command: command, options: dataSource.optionsForCommand(command))
                }
            case .command:
                if components.count <= 1 {
                    self.state = .empty(commands: dataSource.allCommandsForAutoCompletion())
                }
            }

            // Update the completions list, since the text changed.
            self.updateCompletions()
        }
    }

    /// A set of completions to be displayed to the user. Updated when the `currentCommand` changes.
    private(set) var completions: [String] = [] {
        didSet { self.delegate?.autoCompleteManagerDidChangeCompletions() }
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
    }

    /// Reload state & completions from the data source.
    private func reloadData() {
        // Update state based on information from data source.
        if let dataSource = dataSource {
            switch self.state {
            case .empty:
                self.state = .empty(commands: dataSource.allCommandsForAutoCompletion())
            case .command(let command, _):
                self.state = .command(command: command, options: dataSource.optionsForCommand(command))
            }
        } else {
            self.state = .empty(commands: [])
        }

        self.updateCompletions()
    }

    /// Update the value of the `completions` property, based on the current command and state.
    private func updateCompletions() {
        let lastComponent = currentCommand.components(separatedBy: .whitespaces).last ?? ""
        switch state {
        case .empty(let commands):
            self.completions = commands.filter { $0.hasPrefix(lastComponent) }
        case .command(_, let options):
            self.completions = options.filter { $0.hasPrefix(lastComponent) }
        }
    }
}
