//
//  TerminalView.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 09/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit
import InputAssistant

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
	var currentCommandStartIndex: String.Index! {
		didSet { self.updateAutoComplete() }
	}

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

		keyboardObserver.observe { (state) in

			let rect = self.textView.convert(state.keyboardFrameEnd, from: nil).intersection(self.textView.bounds)

			UIView.animate(withDuration: state.duration, delay: 0.0, options: state.options, animations: {

				self.textView.contentInset.bottom = rect.height
				self.textView.scrollIndicatorInsets.bottom = rect.height

			}, completion: nil)

		}

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
		dispatchPrecondition(condition: .onQueue(.main))

		let text = NSMutableAttributedString.init(attributedString: text)
		OutputSanitizer.sanitize(text.mutableString)

		let new = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
		new.append(text)
		textView.attributedText = new

		let rect = textView.caretRect(for: textView.endOfDocument)
		textView.scrollRectToVisible(rect, animated: true)
		self.textView.isScrollEnabled = false
		self.textView.isScrollEnabled = true
	}
	
	private func appendText(_ text: String) {
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
		performOnMain {
			self.appendText(string)
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
		guard let firstCompletion = autoCompleteManager.completions.first?.name,
			currentCommand != firstCompletion else {
				return
		}

		let completed: String
		if let lastCommand = currentCommand.components(separatedBy: " ").last {
			if lastCommand.isEmpty {
				completed = currentCommand + firstCompletion
			} else {
				completed = currentCommand.replacingOccurrences(of: lastCommand, with: firstCompletion, options: .backwards)
			}
		} else {
			completed = firstCompletion
		}

		currentCommand = completed
		autoCompleteManager.reloadData()
	}
}

extension TerminalView: ParserDelegate {

	func parserDidEndTransmission(_ parser: Parser) {
		DispatchQueue.main.async {
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
}

extension TerminalView: UITextDragDelegate {

	func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
		return []
	}

}

extension TerminalView: UITextDropDelegate {

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

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

		switch executor.state {
		case .running:
			executor.sendInput(text)
			return true
		case .idle:
			let i = textView.text.distance(from: textView.text.startIndex, to: currentCommandStartIndex)

			if range.location < i {
				return false
			}

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
		}
	}

	func textViewDidChange(_ textView: UITextView) {
		updateAutoComplete()
	}

}
