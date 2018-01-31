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

}

@IBDesignable
class TerminalView: UIView {

	let deviceName = UIDevice.current.name
	let textView = TerminalTextView()
    let inputAssistantView = InputAssistantView()
    let autoCompleteManager = AutoCompleteManager()

	let keyboardObserver = KeyboardObserver()

    var currentCommandStartIndex: String.Index! {
        didSet { self.updateAutoComplete() }
    }

	weak var delegate: TerminalViewDelegate?

	private var isWaitingForCommand = false

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

    // Display a prompt at the beginning of the line.
    func writePrompt() {
        newLine()
        textView.text = textView.text + "\(deviceName): "
        currentCommandStartIndex = textView.text.endIndex
    }

    // Appends the given string to the output, and updates the command start index.
    func writeOutput(_ string: String) {
        var string = string
        if !string.hasSuffix("\n") {
            string += "\n"
        }
        textView.text = textView.text + string
        currentCommandStartIndex = textView.text.endIndex
    }

    // Moves the cursor to a new line, if it's not already
    func newLine() {
        if !textView.text.hasSuffix("\n") && !textView.text.isEmpty {
            textView.text = textView.text + "\n"
        }
        currentCommandStartIndex = textView.text.endIndex
    }

    // Clears the contents of the screen, resetting the terminal.
	func clearScreen() {
		currentCommandStartIndex = nil
		textView.text = ""
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

			if let currentCommandStartIndex = currentCommandStartIndex, currentCommandStartIndex <= textView.text.endIndex {
				let currentCmdRange = currentCommandStartIndex..<textView.text.endIndex
				textView.text.replaceSubrange(currentCmdRange, with: "")
			}

			textView.text.append(newValue)

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

		guard !isWaitingForCommand else {
			return false
		}

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

	func textViewDidChange(_ textView: UITextView) {
        updateAutoComplete()
	}

}
