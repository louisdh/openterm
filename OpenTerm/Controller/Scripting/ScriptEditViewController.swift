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

protocol ScriptEditViewControllerDelegate: class {
	func didImportExample()
}

class ScriptEditViewController: UIViewController {

	weak var delegate: ScriptEditViewControllerDelegate?
	
	var url: URL
	let contentWrapperView = UIView()
	let document: PridelandDocument
	let textView: SyntaxTextView
	let autoCompleteManager: CubSyntaxAutoCompleteManager
	let inputAssistantView: InputAssistantView
	var autoCompleter: AutoCompleter!

	var cubManualPanelViewController: PanelViewController!
	var cubDocsPanelViewController: PanelViewController!

	let isExample: Bool
	
	init(url: URL, isExample: Bool) {
		self.url = url
		self.isExample = isExample
		
		self.textView = SyntaxTextView()
		self.autoCompleteManager = CubSyntaxAutoCompleteManager()
		self.inputAssistantView = InputAssistantView()
		self.document = PridelandDocument(fileURL: url)

		super.init(nibName: nil, bundle: nil)
		
		inputAssistantView.leadingActions = [
			InputAssistantAction(image: ScriptEditViewController.tabImage, target: self, action: #selector(insertTab))
		]
		
		self.textView.contentTextView.indicatorStyle = .white
		
		let cubManualURL = Bundle.main.url(forResource: "book", withExtension: "html", subdirectory: "cub-guide.htmlcontainer")!
		let cubManualVC = UIStoryboard.main.manualWebViewController(htmlURL: cubManualURL)
		cubManualPanelViewController = PanelViewController(with: cubManualVC, in: self)
		cubManualVC.title = "The Cub Programming Language"
		
		let cubDocsVC = UIStoryboard.main.cubDocumentationViewController()
		cubDocsPanelViewController = PanelViewController(with: cubDocsVC, in: self)
		cubDocsVC.title = "Documentation"

		cubDocsPanelViewController.panelNavigationController.view.backgroundColor = .panelBackgroundColor
		cubDocsPanelViewController.view.backgroundColor = .clear
		
		autoCompleter = AutoCompleter(documentation: cubDocsVC.docBundle.items)
		
		if isExample {
			
			self.textView.contentTextView.isEditable = false
			
		}
		
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
	
	private static var tabImage: UIImage {
		return UIGraphicsImageRenderer(size: .init(width: 24, height: 24)).image(actions: { context in
			
			let path = UIBezierPath()
			path.move(to: CGPoint(x: 1, y: 12))
			path.addLine(to: CGPoint(x: 20, y: 12))
			path.addLine(to: CGPoint(x: 15, y: 6))
			
			path.move(to: CGPoint(x: 20, y: 12))
			path.addLine(to: CGPoint(x: 15, y: 18))
			
			path.move(to: CGPoint(x: 23, y: 6))
			path.addLine(to: CGPoint(x: 23, y: 18))
			
			UIColor.white.setStroke()
			path.lineWidth = 2
			path.lineCapStyle = .butt
			path.lineJoinStyle = .round
			path.stroke()
			
			context.cgContext.addPath(path.cgPath)
			
		}).withRenderingMode(.alwaysOriginal)
	}
	
	@objc func insertTab() {
		
		textView.insertText("\t")
		
	}

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
		
		if !isExample {
			inputAssistantView.attach(to: textView.contentTextView)
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
		
		let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareDocument(_:)))


		if isExample {

			let importBarButtonItem = UIBarButtonItem(title: "Import", style: .done, target: self, action: #selector(importExample(_:)))
			navigationItem.rightBarButtonItems = [importBarButtonItem]

		} else {
			
			navigationItem.rightBarButtonItems = [infoBarButtonItem, shareBarButtonItem, manualBarButtonItem, docsBarButtonItem]

		}
		
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
	func importExample(_ sender: UIBarButtonItem) {
		
		guard let metadata = document.metadata else {
			return
		}
		
		let newUrl = DocumentManager.shared.scriptsURL.appendingPathComponent("\(metadata.name).prideland")
		
		do {
			
			try FileManager.default.copyItem(at: url, to: newUrl)
			self.navigationController?.popViewController(animated: true)
			delegate?.didImportExample()
			
		} catch {
			self.showErrorAlert(error)
		}
	
	}
	
	@objc
	func shareDocument(_ sender: UIBarButtonItem) {

		textView.contentTextView.resignFirstResponder()
		
		let activityItems: [Any] = [url]
		
		let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
		
		activityVC.popoverPresentationController?.barButtonItem = sender
		
		self.present(activityVC, animated: true, completion: nil)
		
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
	
	func didDeleteScript() {
		self.navigationController?.popViewController(animated: true)
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
		
		let suggestions = autoCompleter.completionSuggestions(for: textView.text, cursor: cursor)
		
		return suggestions.map({ CubSyntaxAutoCompleteManager.Completion($0.content, data: $0) })
	}

}

extension ScriptEditViewController: InputAssistantViewDelegate {
	
	func inputAssistantView(_ inputAssistantView: InputAssistantView, didSelectSuggestionAtIndex index: Int) {
		let completion = autoCompleteManager.completions[index]

		let suggestion = completion.data
		
		textView.insertText(suggestion.content)
		
		let newSource = textView.text
		
		let insertStart = newSource.index(newSource.startIndex, offsetBy: suggestion.insertionIndex)
		let cursorAfterInsertion = newSource.index(insertStart, offsetBy: suggestion.cursorAfterInsertion)
		
		if let utf16Index = cursorAfterInsertion.samePosition(in: newSource) {
			let distance = newSource.utf16.distance(from: newSource.utf16.startIndex, to: utf16Index)
			
			textView.contentTextView.selectedRange = NSRange(location: distance, length: 0)
		}
		
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
