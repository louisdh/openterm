//
//  TerminalView.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 09/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit
import InputAssistant
import MobileCoreServices

protocol TerminalViewDelegate: class {

	func didEnterCommand(_ command: String)
	func commandDidEnd()
	func didChangeCurrentWorkingDirectory(_ workingDirectory: URL)

}

@IBDesignable
class TerminalView: UIView {

	let deviceName = UIDevice.current.name
	let executor = CommandExecutor()
	let textView = TerminalTextView()
	let inputAssistantView = InputAssistantView()
	let autoCompleteManager = AutoCompleteManager()

	let keyboardObserver = KeyboardObserver()

	var stdoutParser = Parser()
	var stderrParser = Parser()
	
	private var currentCommandStartIndex: String.Index! {
		didSet {
			updateAutoComplete()
			updateCompletion()
		}
	}
	
	func updateCompletion() {
		
		guard let completion = self.autoCompleteManager.completions.first, currentCommand != "" else {
			
			if let description = CommandManager.shared.description(for: currentCommand), !description.isEmpty {
				textView.autoCompletion = " (\(description))"
			} else {
				textView.autoCompletion = ""
			}
			
			return
		}
		
		let completionString: String
		
		switch autoCompleteManager.state {
		case .executing:
			completionString = ""
			
		default:
			// Two options:
			// - There is a space at the end => insert full word
			// - Complete current word
			
			let currentCommand = self.currentCommand
			if currentCommand.hasSuffix(" ") || currentCommand.hasSuffix("/") {
				// This will be a new argument, or append to the end of a path. Just insert the text.
				completionString = completion.name

			} else {
				// We need to complete the current argument
				var components = currentCommand.components(separatedBy: .whitespaces)
				if let lastComponent = components.popLast() {
					// If the argument we are completing is a path, we must only replace the last part of the path
					if lastComponent.contains("/") {
						components.append(((lastComponent as NSString).deletingLastPathComponent as NSString).appendingPathComponent(completion.name))
					} else {
						components.append(completion.name)
					}
				}
				
				var str = String(components.joined(separator: " ").dropFirst(currentCommand.count))
				
				if let description = CommandManager.shared.description(for: completion.name), !description.isEmpty {
					str += " (\(description))"
				}
				
				completionString = str
				
			}
			
		}
		
		textView.autoCompletion = completionString
		
	}
	
	var columnWidth: Int {
		
		guard let font = textView.font else {
			assertionFailure("Expected font")
			return 0
		}
		
		// TODO: check if the bounds includes the safe area (on iPhone X)
		let viewWidth = textView.bounds.width

		let dummyAtributedString = NSAttributedString(string: "X", attributes: [.font: font])
		let charWidth = dummyAtributedString.size().width
		
		// Assumes the font is monospaced
		return Int(viewWidth / charWidth)
	}

	var didEnterInput: ((String) -> Void)?
	var subCommandParserDidEndTransmissionCallback: (() -> Void)?
	var subCommandParserDidEndTransmissionCallbackCapturingOutput: ((String) -> Void)?

	var captureOutput = false
	var capturedOutput: String?
	
	weak var delegate: TerminalViewDelegate?

	init() {
		super.init(frame: .zero)

		setup()

	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		setup()
	}

	private func setup() {

		stdoutParser.delegate = self
		stderrParser.delegate = self
		executor.delegate = self

		textView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(textView)

		textView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		textView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

		textView.delegate = self

		self.writePrompt()

		textView.textDragDelegate = self
		textView.textDropDelegate = self

		self.setupAutoComplete()

		textView.contentInsetAdjustmentBehavior = .always
		
		keyboardObserver.observe { [weak self] (state) in
			self?.adjustInsets(for: state)
		}
		
		updateCompletion()

	}
	
	private func adjustInsets(for state: KeyboardEvent) {
		
		let rect = self.textView.convert(state.keyboardFrameEnd, from: nil).intersection(self.textView.bounds)
		
		UIView.animate(withDuration: state.duration, delay: 0.0, options: state.options, animations: {
			
			if rect.height == 0 {
				
				// Keyboard is not visible.
				
				self.textView.contentInset.bottom = 0
				self.textView.scrollIndicatorInsets.bottom = 0
				
			} else {
				
				// Keyboard is visible, keyboard height includes safeAreaInsets.
				
				let bottomInset = rect.height - self.safeAreaInsets.bottom
				
				self.textView.contentInset.bottom = bottomInset
				self.textView.scrollIndicatorInsets.bottom = bottomInset
				
			}
			
		}, completion: nil)
		
	}

	/// Performs the given block on the main thread, without dispatching if already there.
	func performOnMain(_ block: @escaping () -> Void) {
		if Thread.isMainThread {
			block()
		} else {
			DispatchQueue.main.async(execute: block)
		}
	}

	func appendText(_ text: NSAttributedString) {
		
		if text.string.isEmpty {
			return
		}
		
		if captureOutput {
			capturedOutput = (capturedOutput ?? "") + text.string
			return
		}
		
		dispatchPrecondition(condition: .onQueue(.main))

		let text = NSMutableAttributedString(attributedString: text)
		OutputSanitizer.sanitize(text.mutableString)

		let new = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
		new.append(text)
		textView.attributedText = new

		let rect = textView.caretRect(for: textView.endOfDocument)
		textView.scrollRectToVisible(rect, animated: true)
		self.textView.isScrollEnabled = false
		self.textView.isScrollEnabled = true
	}
	
	func appendText(_ text: String) {

		dispatchPrecondition(condition: .onQueue(.main))

		appendText(NSAttributedString(string: text, attributes: [.foregroundColor: textView.textColor ?? .black, .font: textView.font!]))
	}

	// Display a prompt at the beginning of the line.
	func writePrompt() {
		newLine()
		appendText("\(deviceName): ")
		currentCommandStartIndex = textView.text.endIndex
	}

	// Appends the given string to the output, and updates the command start index.
	func writeOutput(_ string: String) {
		performOnMain {
			self.appendText(string)
			self.currentCommandStartIndex = self.textView.text.endIndex
		}
	}
	
	func writeOutput(_ string: NSAttributedString) {
		let withLinks = string.withFilesAsLinks(currentDirectory: executor.currentWorkingDirectory.path)

		performOnMain {
			self.appendText(withLinks)
			self.currentCommandStartIndex = self.textView.text.endIndex
		}
	}

	// Moves the cursor to a new line, if it's not already
	func newLine() {
		if !textView.text.hasSuffix("\n") && !textView.text.isEmpty {
			appendText("\n")
		}
		currentCommandStartIndex = textView.text.endIndex
	}

	// Clears the contents of the screen, resetting the terminal.
	func clearScreen() {
		currentCommandStartIndex = nil
		textView.text = ""
		stdoutParser.reset()
		stderrParser.reset()
	}

	@discardableResult
	override func becomeFirstResponder() -> Bool {
		return textView.becomeFirstResponder()
	}

	@discardableResult
	override func resignFirstResponder() -> Bool {
		return textView.resignFirstResponder()
	}
	
	override var canBecomeFirstResponder: Bool {
		return textView.canBecomeFirstResponder
	}
	
	var currentCommand: String {
		get {

			guard let currentCommandStartIndex = currentCommandStartIndex, currentCommandStartIndex <= textView.text.endIndex else {
				return ""
			}

			let currentCmdRange = currentCommandStartIndex..<textView.text.endIndex

			return String(textView.text[currentCmdRange])
		}
		set {

			// Remove current command, if present
			if let currentCommandStartIndex = currentCommandStartIndex, currentCommandStartIndex <= textView.text.endIndex {
				let currentCmdRange = currentCommandStartIndex..<textView.text.endIndex
				let attributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
				attributedString.replaceCharacters(in: NSRange(currentCmdRange, in: textView.text), with: NSAttributedString())
				textView.attributedText = attributedString
			}

			// Add new current command
			appendText(newValue)
		}
	}
}

// MARK: Key commands
extension TerminalView {

	override var keyCommands: [UIKeyCommand]? {
		return [
			// Clear
			UIKeyCommand(input: "K", modifierFlags: .command, action: #selector(clearBufferCommand), discoverabilityTitle: "Clear Buffer"),

			// Stop
			UIKeyCommand(input: "C", modifierFlags: .control, action: #selector(stopCurrentCommand), discoverabilityTitle: "Stop Running Command"),

			// Text selection, navigation
			UIKeyCommand(input: "A", modifierFlags: .control, action: #selector(selectCommandHome), discoverabilityTitle: "Beginning of Line"),
			UIKeyCommand(input: "E", modifierFlags: .control, action: #selector(selectCommandEnd), discoverabilityTitle: "End of Line"),

			// Tab completion
			UIKeyCommand(input: "\t", modifierFlags: [], action: #selector(completeCommand), discoverabilityTitle: "Complete")
		]
	}

	@objc func clearBufferCommand() {
		clearScreen()
		writePrompt()
	}

	@objc private func stopCurrentCommand() {
		// Send CTRL+C character to running command
		guard executor.state == .running else {
			return
		}
		
		let character = Parser.Code.endOfText.rawValue
		textView.insertText(character)
		executor.sendInput(character)
	}

	@objc func selectCommandHome() {
		let commandStartDifference = textView.text.distance(from: currentCommandStartIndex, to: textView.text.endIndex)
		if let commandStartPosition = textView.position(from: textView.endOfDocument, offset: -commandStartDifference) {
			textView.selectedTextRange = textView.textRange(from: commandStartPosition, to: commandStartPosition)
		}
	}

	@objc func selectCommandEnd() {
		let endPosition = textView.endOfDocument
		textView.selectedTextRange = textView.textRange(from: endPosition, to: endPosition)
	}

	@objc func completeCommand() {

		guard let firstCompletion = autoCompleteManager.completions.first, currentCommand != firstCompletion.name else {
			return
		}

		insertCompletion(firstCompletion)
	}
}

extension TerminalView: ParserDelegate {

	func parserDidEndTransmission(_ parser: Parser) {

		DispatchQueue.main.async {

			if let callback = self.subCommandParserDidEndTransmissionCallbackCapturingOutput {
				callback(self.capturedOutput ?? "")
				return
			}
			
			if let callback = self.subCommandParserDidEndTransmissionCallback {
				callback()
				return
			}
			
			self.writePrompt()
		}
	}

	func parser(_ parser: Parser, didReceiveString string: NSAttributedString) {
		self.writeOutput(string)
	}
}

extension TerminalView: CommandExecutorDelegate {

	func commandExecutor(_ commandExecutor: CommandExecutor, receivedStdout stdout: Data) {
		stdoutParser.parse(stdout)
	}
	
	func commandExecutor(_ commandExecutor: CommandExecutor, receivedStderr stderr: Data) {
		stderrParser.parse(stderr)
	}

	func commandExecutor(_ commandExecutor: CommandExecutor, didChangeWorkingDirectory to: URL) {
		DispatchQueue.main.async {
			self.delegate?.didChangeCurrentWorkingDirectory(to)
		}
	}

	func commandExecutor(_ commandExecutor: CommandExecutor, stateDidChange newState: CommandExecutor.State) {
		DispatchQueue.main.async {
			self.updateAutoComplete()
		}
	}
	
	func commandExecutor(_ commandExecutor: CommandExecutor, waitForInput callback: @escaping (String) -> Void) {
	
		didEnterInput = callback
		currentCommandStartIndex = textView.text.endIndex
		executor.state = .waitingForInput
		
	}
	
	func commandExecutor(_ commandExecutor: CommandExecutor, executeSubCommand subCommand: String, callback: @escaping (Int) -> Void) {
		
		subCommandParserDidEndTransmissionCallback = { [weak self] in
			
			self?.subCommandParserDidEndTransmissionCallback = nil
			
			let intStatus: Int
			
			if let status = self?.executor.context[.status] {
				intStatus = Int(status) ?? 1
			} else {
				intStatus = 1
			}
			
			callback(intStatus)
		}
		
		commandExecutor.dispatch(subCommand)
		
	}
	
	func commandExecutor(_ commandExecutor: CommandExecutor, executeSubCommand subCommand: String, capturingOutput callback: @escaping (String) -> Void) {
		
		captureOutput = true
		
		subCommandParserDidEndTransmissionCallbackCapturingOutput = { [weak self] (output) in
			
			self?.subCommandParserDidEndTransmissionCallbackCapturingOutput = nil
			self?.capturedOutput = nil
			self?.captureOutput = false
			callback(output)
		}
		
		commandExecutor.dispatch(subCommand)
		
	}
	
}

extension TerminalView: UITextDragDelegate {

	private func previewForDrag(dragRequest: UITextDragRequest) -> UIDragPreview {
		let label = UILabel()
		label.text = textView.text(in: dragRequest.dragRange)
		label.backgroundColor = UIColor.clear
		label.textColor = textView.textColor
		label.font = textView.font
		label.textAlignment = .center
		var size = label.sizeThatFits(CGSize(width: 300, height: 200))
		size.width += 10
		size.height += 10
		label.frame = CGRect(origin: CGPoint.zero, size: size)
		
		let parameters = UIDragPreviewParameters()
		parameters.visiblePath = UIBezierPath.init(roundedRect: label.bounds, cornerRadius: 7)
		
		let preview = UIDragPreview(view:label, parameters:parameters)
		return preview
	}
	
	func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
		// allow dragging URLs
		var items = [UIDragItem]()
		for item in dragRequest.suggestedItems {
			let fileURLType = kUTTypeFileURL as String
			if item.itemProvider.hasItemConformingToTypeIdentifier(fileURLType) {
				
				// determine uti making sure not to use dynamic type
				let filename = (textView.text(in: dragRequest.dragRange) ?? "") as NSString
				let uti_ns = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, filename.pathExtension as CFString, nil)?.takeRetainedValue() as NSString?
				var uti = uti_ns != nil ? String(uti_ns!) : (kUTTypeFileURL as String)
				if uti.hasPrefix("dyn.") { uti = kUTTypeFileURL as String }
				
				let provider = NSItemProvider()
				provider.registerFileRepresentation(forTypeIdentifier: uti, fileOptions: .openInPlace, visibility: .all,
													loadHandler: { (completion) in
														
					// read url from source provider
					let _ = item.itemProvider.loadObject(ofClass: URL.self,
														 completionHandler: { (reader, error) in
						completion(reader, true, error)
					})
														
					return nil
				})
				provider.suggestedName = String(filename)
				
				let dragItem = UIDragItem(itemProvider: provider)
				
				
				// We want to set url from attributtedText directory
				textView.attributedText.enumerateAttribute(.link, in: textView.range(dragRequest.dragRange), options: [],
														   using: { (link, _, _) in
					if link is String {
						dragItem.localObject = URL(string: link! as! String)
					} else if(link is URL) {
						dragItem.localObject = link! as! URL
					}
				})
				
				// use label of dragged text as preview
				dragItem.previewProvider = { return self.previewForDrag(dragRequest: dragRequest) }
				items.append(dragItem)
			}
		}
		return items
	}

}

extension TerminalView: UITextDropDelegate {
	func textDroppableView(_ textDroppableView: UIView & UITextDroppable, proposalForDrop drop: UITextDropRequest) -> UITextDropProposal {
		let proposal = UITextDropProposal(operation: UIDropOperation.copy)
		proposal.useFastSameViewOperations = false
		proposal.dropAction = .replaceSelection
		return proposal
	}
	
	func textDroppableView(_ textDroppableView: UIView & UITextDroppable, willPerformDrop drop: UITextDropRequest) {
		textView.pasteDelegate = self
	}
	
	func textDroppableView(_ textDroppableView: UIView & UITextDroppable,
						   dropSessionDidEnd session: UIDropSession) {
		// move cursor to end of document when finished with drop
		let end = textView.endOfDocument
		textView.selectedTextRange = textView.textRange(from: end, to: end)
		textView.becomeFirstResponder()
		textView.pasteDelegate = nil
	}
}

extension TerminalView : UITextPasteDelegate {
	func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting,
										  transform item: UITextPasteItem) {
		
		// try to pick result from localObject
		if let localUrl: URL = item.localObject as! URL? {
			let currentDirectory = self.executor.currentWorkingDirectory.path
			let result = relative(filename: localUrl.path, to: currentDirectory)
			item.setResult(string: result)
			return
		}

		// we want to paste as the first public type
		for uti in item.itemProvider.registeredTypeIdentifiers {
			if uti.hasPrefix("public.") {
				paste(item: item, uti:uti)
				return
			}
			
		}
		
		// we only get to this point if there are no public types
		let uti = item.itemProvider.registeredTypeIdentifiers.first ?? (kUTTypeFileURL as String)
		paste(item: item, uti:uti)
	}
	
	private func paste(item: UITextPasteItem, uti: String) {
		item.itemProvider.loadInPlaceFileRepresentation(forTypeIdentifier: uti,
														completionHandler: { url, inPlace, error in
															
			guard let url = url else { return }
															
				if inPlace {
					let _ = url.startAccessingSecurityScopedResource()
					let currentDirectory = self.executor.currentWorkingDirectory.path
					let result = relative(filename: url.path, to: currentDirectory)
					item.setResult(string: result)
					url.stopAccessingSecurityScopedResource()
				} else {
					// make sure we have /tmp/drop folder
					let tempFolder = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("drop")
					try? FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
																
					// copy to /tmp/drop folder
					let filename = url.lastPathComponent
					let tempUrl = tempFolder.appendingPathComponent(filename).unused()
					do {
						try FileManager.default.copyItem(at: url, to: tempUrl)
						item.setResult(string: tempUrl.path)
					} catch {
						NSLog("Unable to create temp file: \(error)")
					}
				}
		})
	}
}

extension TerminalView: UITextViewDelegate {

	func textViewDidChangeSelection(_ textView: UITextView) {

		//		if currentCommandStartIndex == nil {
		//			return
		//		}
		//
		//		let i = textView.text.distance(from: textView.text.startIndex, to: currentCommandStartIndex)
		//
		//		if textView.selectedRange.location < i {
		//			textView.selectedRange = NSMakeRange(i, 0)
		//		}
		//
	}
	
	func waitForInput() {
		
		currentCommandStartIndex = textView.text.endIndex
		executor.state = .waitingForInput
		
	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

		// Use utf16, because NSRange uses that, and we need to compare its location.
		let i = textView.text.utf16.distance(from: textView.text.utf16.startIndex, to: currentCommandStartIndex)
		
		if range.location < i {
			return false
		}
		
		switch executor.state {
		case .running:
			executor.sendInput(text)
			return true
		case .idle:

			if text == "\n" {

				let input = textView.text[currentCommandStartIndex..<textView.text.endIndex]

				if input.isEmpty {
					writePrompt()
				} else {
					newLine()
					delegate?.didEnterCommand(String(input))
				}
				return false
			}

			return true
			
		case .waitingForInput:
			
			if text == "\n" {
			
				self.executor.state = .running
				
				let input = textView.text[currentCommandStartIndex..<textView.text.endIndex]
				
				newLine()
				didEnterInput?(String(input))
				
				return false
			}
			
			return true
		}
		
	}

	func textViewDidChange(_ textView: UITextView) {
		updateAutoComplete()
		updateCompletion()
	}

}
