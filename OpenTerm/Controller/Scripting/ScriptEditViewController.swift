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
import PanelKit

class ScriptEditViewController: UIViewController {

	var script: Script
	let textView: SyntaxTextView
	let autoCompleteManager: CubSyntaxAutoCompleteManager
	let inputAssistantView: InputAssistantView

	init(script: Script) {
		self.script = script
		self.textView = SyntaxTextView()
		self.autoCompleteManager = CubSyntaxAutoCompleteManager()
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

	private var textViewSelectedRangeObserver: NSKeyValueObservation?

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.tintColor = .defaultMainTintColor
		self.navigationController?.navigationBar.barStyle = .blackTranslucent
		
		textView.delegate = self

		// Set up auto complete manager
		autoCompleteManager.delegate = inputAssistantView
		autoCompleteManager.dataSource = self

		// Set up input assistant and text view for auto completion
		inputAssistantView.delegate = self
		inputAssistantView.dataSource = autoCompleteManager
		inputAssistantView.attach(to: textView.contentTextView)

		textViewSelectedRangeObserver = textView.contentTextView.observe(\UITextView.selectedTextRange) { [weak self] (textView, value) in
			
			self?.autoCompleteManager.reloadData()

		}
		
		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(showScriptMetadata), for: .touchUpInside)
		
		let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
		navigationItem.rightBarButtonItem = infoBarButtonItem
		
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		textView.text = script.value
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		textView.becomeFirstResponder()
	}
	
	@objc
	func showScriptMetadata() {
		
		let scriptMetadataVC = UIStoryboard.main.scriptMetadataViewController(state: .update)
		
		let navController = UINavigationController(rootViewController: scriptMetadataVC)
		navController.navigationBar.barStyle = .blackTranslucent
		navController.modalPresentationStyle = .formSheet
		
		self.present(navController, animated: true, completion: nil)
		
	}

	private func save() {
		// Save to disk
		script.value = textView.text
	}

}

extension ScriptEditViewController: PanelContentDelegate {

	var preferredPanelContentSize: CGSize {
		return CGSize(width: 320, height: 480)
	}
	
	var minimumPanelContentSize: CGSize {
		return CGSize(width: 320, height: 320)
	}
	
	var maximumPanelContentSize: CGSize {
		return CGSize(width: 600, height: 800)
	}
	
	var shouldAdjustForKeyboard: Bool {
		return self.textView.contentTextView.isFirstResponder
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

extension ScriptEditViewController: CubSyntaxAutoCompleteManagerDataSource {

	func completions() -> [CubSyntaxAutoCompleteManager.Completion] {
		
		let autoCompletor = AutoCompleter()
		
		let selectedRange = textView.contentTextView.selectedRange
		let cursor = selectedRange.location + selectedRange.length - 1
		
		let suggestions = autoCompletor.completionSuggestions(for: textView.text, cursor: cursor)
		
		return suggestions.map({ CubSyntaxAutoCompleteManager.Completion($0.content, data: $0) })
	}

}

extension ScriptEditViewController: InputAssistantViewDelegate {
	
	func inputAssistantView(_ inputAssistantView: InputAssistantView, didSelectSuggestionAtIndex index: Int) {
		let completion = autoCompleteManager.completions[index]

		let suggestion = completion.data
		
		textView.contentTextView.insertText(suggestion.content)

	}
	
}
