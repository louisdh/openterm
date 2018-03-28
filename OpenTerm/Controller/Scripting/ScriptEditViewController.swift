//
//  ScriptEditViewController.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/29/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import InputAssistant

class ScriptEditViewController: UIViewController {

	var script: Script
	let textView: TerminalTextView
	let autoCompleteManager: AutoCompleteManager
	let inputAssistantView: InputAssistantView

	init(script: Script) {
		self.script = script
		self.textView = TerminalTextView()
		self.autoCompleteManager = AutoCompleteManager()
		self.inputAssistantView = InputAssistantView()
		super.init(nibName: nil, bundle: nil)
		self.title = script.name
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		view = textView
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		textView.delegate = self

		// Set up auto complete manager
		self.autoCompleteManager.delegate = self.inputAssistantView
		self.autoCompleteManager.dataSource = self

		// Set up input assistant and text view for auto completion
		self.inputAssistantView.delegate = self
		self.inputAssistantView.dataSource = self.autoCompleteManager
		self.textView.inputAccessoryView = self.inputAssistantView
		self.inputAssistantView.tintColor = .lightGray

		// Hide default undo/redo/etc buttons
		textView.inputAssistantItem.leadingBarButtonGroups = []
		textView.inputAssistantItem.trailingBarButtonGroups = []

		// Disable built-in autocomplete
		textView.autocorrectionType = .no
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		textView.becomeFirstResponder()
		textView.text = script.value
	}

	private func save() {
		// Save to disk
		script.value = textView.text
	}

}

extension ScriptEditViewController: UITextViewDelegate {

	func textViewDidChange(_ textView: UITextView) {
		save()
		autoCompleteManager.reloadData()
	}
}

extension ScriptEditViewController: AutoCompleteManagerDataSource {

	func allCommandsForAutoCompletion() -> [String] {
		return ["+ new argument"] + self.script.argumentNames
	}

	func completionsForProgram(_ command: String, _ currentArguments: [String]) -> [AutoCompleteManager.Completion] {
		return []
	}

	func completionsForExecution() -> [AutoCompleteManager.Completion] {
		return []
	}

	func availableCompletions(in completions: [AutoCompleteManager.Completion], forArguments arguments: [String]) -> [AutoCompleteManager.Completion] {
		return completions
	}
}

extension ScriptEditViewController: InputAssistantViewDelegate {
	func inputAssistantView(_ inputAssistantView: InputAssistantView, didSelectSuggestionAtIndex index: Int) {
		let suggestion = autoCompleteManager.completions[index]

		if suggestion.name == "+ new argument" {
			textView.insertText("$<<argument>>")
		} else {
			textView.insertText("$<<\(suggestion.name)>>")
		}
	}
}
