//
//  ScriptEditViewController.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 21/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import InputAssistant
import Cub
import SavannaKit
import PanelKit

class ScriptEditViewController: UIViewController {

	var url: URL
	let contentWrapperView = UIView()
	let document: PridelandDocument
	let textView: SyntaxTextView
	let autoCompleteManager: CubSyntaxAutoCompleteManager
	let inputAssistantView: InputAssistantView
	let autoCompletor = AutoCompleter()

	var cubManualPanelViewController: PanelViewController!
	var cubDocsPanelViewController: PanelViewController!

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
		
		let cubDocsVC = UIStoryboard.main.cubDocumentationViewController()
		cubDocsPanelViewController = PanelViewController(with: cubDocsVC, in: self)
		cubDocsVC.title = "Documentation"

		cubDocsPanelViewController.panelNavigationController.view.backgroundColor = .panelBackgroundColor
		cubDocsPanelViewController.view.backgroundColor = .clear
		
	}
	
	private func setupViews() {
		
		// Content wrapper is root view
		contentWrapperView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(contentWrapperView)
		
		NSLayoutConstraint.activate([
			contentWrapperView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			contentWrapperView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			contentWrapperView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
			contentWrapperView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			])
		
		contentWrapperView.backgroundColor = .black
		
		textView.translatesAutoresizingMaskIntoConstraints = false
		contentWrapperView.addSubview(textView)
		
		NSLayoutConstraint.activate([
			textView.leadingAnchor.constraint(equalTo: contentWrapperView.leadingAnchor),
			textView.trailingAnchor.constraint(equalTo: contentWrapperView.trailingAnchor),
			textView.topAnchor.constraint(equalTo: contentWrapperView.topAnchor),
			textView.bottomAnchor.constraint(equalTo: contentWrapperView.bottomAnchor)
			])
		
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private var textViewSelectedRangeObserver: NSKeyValueObservation?

	private let keyboardObserver = KeyboardObserver()
	
	var manualBarButtonItem: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		setupViews()
		
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

		let manualButton = UIButton(type: .system)
		manualButton.setTitle("?", for: .normal)
		manualButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
		
		manualButton.addTarget(self, action: #selector(showManual(_:)), for: .touchUpInside)
		
		manualBarButtonItem = UIBarButtonItem(customView: manualButton)
		
		let docsBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showDocs(_:)))
		
		let infoButton = UIButton(type: .system)
		infoButton.setImage(#imageLiteral(resourceName: "Settings"), for: .normal)
		
		infoButton.addTarget(self, action: #selector(showScriptMetadata), for: .touchUpInside)
		
		let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
		
		navigationItem.rightBarButtonItems = [infoBarButtonItem, manualBarButtonItem, docsBarButtonItem]
		
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
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: { (_) in
			
		}, completion: { (_) in
			
			if !self.allowFloatingPanels {
				self.closeAllFloatingPanels()
			}
			
			if !self.allowPanelPinning {
				self.closeAllPinnedPanels()
			}
			
		})
		
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

	@objc
	func showDocs(_ sender: UIBarButtonItem) {
		
		presentPopover(self.cubDocsPanelViewController, from: sender, backgroundColor: .panelBackgroundColor)
		
	}
	
	@objc
	func showManual(_ sender: UIButton) {
	
		presentPopover(self.cubManualPanelViewController, from: manualBarButtonItem, backgroundColor: .white)
		
	}
	
	private func presentPopover(_ viewController: UIViewController, from sender: UIBarButtonItem, backgroundColor: UIColor) {
		
		// prevent a crash when the panel is floating.
		viewController.view.removeFromSuperview()
		
		viewController.modalPresentationStyle = .popover
		viewController.popoverPresentationController?.barButtonItem = sender
		viewController.popoverPresentationController?.backgroundColor = backgroundColor
		
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
	
	func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {
		autoCompleteManager.reloadData()
	}

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
		return [cubManualPanelViewController, cubDocsPanelViewController]
	}
	
	var panelContentWrapperView: UIView {
		return self.contentWrapperView
	}
	
	var panelContentView: UIView {
		return textView
	}
	
	func maximumNumberOfPanelsPinned(at side: PanelPinSide) -> Int {
		return 2
	}
	
}
