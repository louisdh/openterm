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
        self.inputAssistantView.tintColor = .lightGray

        inputAssistantView.trailingActions = [
            InputAssistantAction(image: TerminalView.downArrow, target: self, action: #selector(downTapped))
        ]

        // Hide default undo/redo/etc buttons
        textView.inputAssistantItem.leadingBarButtonGroups = []
        textView.inputAssistantItem.trailingBarButtonGroups = []

        // Disable built-in autocomplete
        textView.autocorrectionType = .no
    }

    /// Updates auto complete when current command changes
    func updateAutoComplete() {
        autoCompleteManager.currentCommand = self.currentCommand
    }

    /// Dismiss the keyboard when the down arrow is tapped
    @objc private func downTapped() {
        textView.resignFirstResponder()
    }

    /// Construct an image for the down arrow.
    private static var downArrow: UIImage {
        return UIGraphicsImageRenderer(size: .init(width: 24, height: 24)).image(actions: { context in

            // Top left to center
            let downwards = UIBezierPath()
            downwards.move(to: CGPoint(x: 1, y: 7))
            downwards.addLine(to: CGPoint(x: 11, y: 17))
            UIColor.white.setStroke()
            downwards.lineWidth = 2
            downwards.stroke()

            // Center to top right
            let upwards = UIBezierPath()
            upwards.move(to: CGPoint(x: 11, y: 17))
            upwards.addLine(to: CGPoint(x: 22, y: 7))
            UIColor.white.setStroke()
            upwards.lineWidth = 2
            upwards.stroke()

            context.cgContext.addPath(downwards.cgPath)
            context.cgContext.addPath(upwards.cgPath)
        }).withRenderingMode(.alwaysOriginal)
    }
}

extension TerminalView: AutoCompleteManagerDataSource {

    func allCommandsForAutoCompletion() -> [String] {
        let allCommands = (commandsAsArray() as? [String] ?? []).sorted()
        return Script.allNames + allCommands + ["help", "clear"]
    }

    func completionsForCommand(_ command: String) -> [AutoCompleteManager.Completion] {
        // If command is a script, return the argument names in options form, for that script. Without ones that are already entered.
        if Script.allNames.contains(command), let script = try? Script.named(command) {
            return script.argumentNames.map { "--\($0)=" }.map { AutoCompleteManager.Completion($0, isStandalone: false) }
        }

        var options: [String] = []

        // Find types of command, and add files/folders in directory
        // depending on if the command can touch those things.
        let commandTypes = CommandTypes.forCommand(command)
        options += itemsInCurrentDirectory(showFolders: commandTypes.contains(.affectsFolders), showFiles: commandTypes.contains(.affectsFiles))

        // TODO: There must be a better way to add flags. Don't want to hard code these per command. Parsing man pages could automate this.
        switch command {
        case "awk":
            options += ["-F", "-v", "-f", "'{", "}'"]
        case "cat":
            options += ["-b", "-e", "-n", "-s", "-t", "-u", "-v"]
        case "ls":
            options += ["-@", "-1", "-A", "-a", "-B", "-b", "-C", "-c", "-d", "-e", "-F", "-f", "-G", "-g", "-H", "-h", "-i", "-k", "-L", "-l", "-m", "-n", "-O", "-P", "-q", "-R", "-r", "-S", "-s", "-T", "-t", "-u", "-U", "-v", "-W", "-w", "-x"]
        default:
            break
        }
        return options.map { AutoCompleteManager.Completion($0) }
    }

    // Get the names of files/folders in the current working directory.
    private func itemsInCurrentDirectory(showFolders: Bool, showFiles: Bool) -> [String] {
        if !showFolders && !showFiles { return [] }

        let fileManager = DocumentManager.shared.fileManager
        do {
            let contents = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: fileManager.currentDirectoryPath), includingPropertiesForKeys: [.isDirectoryKey], options: [])
            let files = try contents.filter { url in
                let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
                let isDirectory = resourceValues.isDirectory ?? false
                return showFolders && isDirectory || showFiles && !isDirectory
            }
            return files.map { $0.lastPathComponent }
        } catch {
            return []
        }
    }
}

extension TerminalView: InputAssistantViewDelegate {

    func inputAssistantView(_ inputAssistantView: InputAssistantView, didSelectSuggestionAtIndex index: Int) {
        // Get the text to insert
        let completion = autoCompleteManager.completions[index]

        // Two options:
        // - There is a space at the end => insert full word
        // - Complete current word

        let currentCommand = self.currentCommand
        if currentCommand.hasSuffix(" ") {
            textView.insertText(completion.name)
        } else {
            var components = currentCommand.components(separatedBy: .whitespaces)
            if let lastComponent = components.popLast() {
                let commonPrefix = lastComponent.commonPrefix(with: completion.name)
                let completedComponent = lastComponent + completion.name.replacingOccurrences(of: commonPrefix, with: "")
                components.append(completedComponent)
            }
            self.currentCommand = components.joined(separator: " ")
        }

        // Insert whitespace at end
        if completion.isStandalone {
            textView.insertText(" ")
        }
    }
}
