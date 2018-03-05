//
//  ScriptEditViewController.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/29/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import InputAssistant
import Cub
import SavannaKit

class ScriptEditViewController: UIViewController {

	var script: Script
	let textView: SyntaxTextView
	let autoCompleteManager: AutoCompleteManager
	let inputAssistantView: InputAssistantView

	init(script: Script) {
		self.script = script
		self.textView = SyntaxTextView()
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
		self.inputAssistantView.attach(to: self.textView.contentTextView)

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		textView.text = script.value
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		textView.becomeFirstResponder()
	}

	private func save() {
		// Save to disk
		script.value = textView.text
	}

}

extension ScriptEditViewController: SyntaxTextViewDelegate {

	func didChangeText(_ syntaxTextView: SyntaxTextView) {
		save()
		autoCompleteManager.reloadData()
	}

	func lexerForSource(_ source: String) -> SavannaKit.Lexer {
		return Cub.Lexer(input: source)
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
		
		let autoCompletor = AutoCompletor()
		
		let selectedRange = textView.contentTextView.selectedRange
		let cursor = selectedRange.location + selectedRange.length - 1
		
		let suggestions = autoCompletor.completionSuggestions(for: textView.text, cursor: cursor)
		
		return suggestions.map({ $0.content })
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

		textView.contentTextView.insertText(suggestion.name)
		
		//        if suggestion.name == "+ new argument" {
		//            textView.insertText("$<<argument>>")
		//        } else {
		//            textView.insertText("$<<\(suggestion.name)>>")
		//        }
	}
}
