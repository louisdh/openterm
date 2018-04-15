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

	var url: URL
	let document: PridelandDocument
	let textView: SyntaxTextView
	let autoCompleteManager: CubSyntaxAutoCompleteManager
	let inputAssistantView: InputAssistantView

	var cubManualPanelViewController: PanelViewController!

	init(url: URL) {
		self.url = url
		self.textView = SyntaxTextView()
		self.autoCompleteManager = CubSyntaxAutoCompleteManager()
		self.inputAssistantView = InputAssistantView()
		self.document = PridelandDocument(fileURL: url)

		super.init(nibName: nil, bundle: nil)
		
		let cubManualURL = Bundle.main.url(forResource: "book", withExtension: "html", subdirectory: "cub-guide.htmlcontainer")!
		let cubManualVC = UIStoryboard.main.manualWebViewController(htmlURL: cubManualURL)
		cubManualPanelViewController = PanelViewController(with: cubManualVC, in: self)
		cubManualVC.title = "The Cub Programming Language"

	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		view = textView
	}

	private var textViewSelectedRangeObserver: NSKeyValueObservation?

	private let keyboardObserver = KeyboardObserver()
	
	
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
		
		
//		cubManualPanelViewController = PanelViewController(with: cubManualVC, in: self)
		
		let manualsBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showManuals(_:)))
		
		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(showScriptMetadata), for: .touchUpInside)
		
		let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
		
		navigationItem.rightBarButtonItems = [infoBarButtonItem, manualsBarButtonItem]
		
		document.open { [weak self] (success) in
			
			if !success {
				
				self?.showErrorAlert(dismissCallback: {
					self?.dismiss(animated: true, completion: nil)
				})
				
			}
			
			self?.textView.text = self?.document.text ?? ""

		}
		
		keyboardObserver.observe { [weak self] (state) in
			self?.adjustInsets(for: state)
		}
		
	}
	
	private func adjustInsets(for state: KeyboardEvent) {
		
		let rect = self.textView.convert(state.keyboardFrameEnd, from: nil).intersection(self.textView.bounds)
		
		UIView.animate(withDuration: state.duration, delay: 0.0, options: state.options, animations: {
			
			if rect.height == 0 {
				
				// Keyboard is not visible.
				
				self.textView.contentInset.bottom = 0
				
			} else {
				
				// Keyboard is visible, keyboard height includes safeAreaInsets.
				
				let bottomInset = rect.height - self.view.safeAreaInsets.bottom
				
				self.textView.contentInset.bottom = bottomInset
				
			}
			
		}, completion: nil)
		
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		textView.contentTextView.becomeFirstResponder()

	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

	}
	
	deinit {
		
		if self.document.documentState != .closed {
			self.document.close(completionHandler: nil)
		}
		
	}
	
	@objc
	func showManuals(_ sender: UIBarButtonItem) {
	
		presentPopover(self.cubManualPanelViewController, from: sender)
		
	}
	
	private func presentPopover(_ viewController: UIViewController, from sender: UIBarButtonItem) {
		viewController.modalPresentationStyle = .popover
		viewController.popoverPresentationController?.barButtonItem = sender
		viewController.popoverPresentationController?.permittedArrowDirections = .up
		viewController.popoverPresentationController?.backgroundColor = viewController.view.backgroundColor
		
		present(viewController, animated: true, completion: nil)
	}
	
	@objc
	func showScriptMetadata() {
		
		let scriptMetadataVC = UIStoryboard.main.scriptMetadataViewController(state: .update(document))
		scriptMetadataVC.delegate = self
		
		let navController = UINavigationController(rootViewController: scriptMetadataVC)
		navController.navigationBar.barStyle = .blackTranslucent
		navController.modalPresentationStyle = .formSheet
		
		self.present(navController, animated: true, completion: nil)
		
	}

	private func save() {
		
		if document.text != textView.text {
			
			document.text = textView.text
			document.updateChangeCount(.done)
			
		}
		
	}

}

extension ScriptEditViewController: ScriptMetadataViewControllerDelegate {
	
	func didUpdateScript(_ updatedDocument: PridelandDocument) {
		self.title = updatedDocument.metadata?.name ?? ""
	}
	
	func didCreateScript(_ document: PridelandDocument) {
		
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
		
		guard let text = textView.contentTextView.text else {
			return []
		}
		
		let selectedRange = textView.contentTextView.selectedRange
		
		guard let swiftRange = Range(selectedRange, in: text) else {
			return []
		}
		
		let cursor = text.distance(from: text.startIndex, to: swiftRange.lowerBound)
		
		let suggestions = autoCompletor.completionSuggestions(for: textView.text, cursor: cursor)
		
		return suggestions.map({ CubSyntaxAutoCompleteManager.Completion($0.content, data: $0) })
	}

}

extension ScriptEditViewController: InputAssistantViewDelegate {
	
	func inputAssistantView(_ inputAssistantView: InputAssistantView, didSelectSuggestionAtIndex index: Int) {
		let completion = autoCompleteManager.completions[index]

		let suggestion = completion.data
		
		textView.insertText(suggestion.content)

		textView.contentTextView.selectedRange = NSRange(location: suggestion.insertionIndex + suggestion.cursorAfterInsertion, length: 0)

	}
	
}

extension ScriptEditViewController: PanelManager {
	
	var panels: [PanelViewController] {
		return [cubManualPanelViewController]
	}
	
	var panelContentWrapperView: UIView {
		return self.view
	}
	
	var panelContentView: UIView {
		return textView
	}
	
}
