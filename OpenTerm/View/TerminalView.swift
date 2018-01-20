//
//  TerminalView.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 09/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit

protocol TerminalProcessor: class {
	
	func process(command: String) -> String
	
}

protocol TerminalViewDelegate: class {
	
	func didEnterCommand(_ command: String)
	
}

@IBDesignable
class TerminalView: UIView {
	
	let deviceName = UIDevice.current.name
	let textView = UITextView()
	
	let keyboardObserver = KeyboardObserver()
	
	var currentCommandStartIndex: String.Index!
	
	weak var processor: TerminalProcessor?
	
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
		
		textView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(textView)
		
		textView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		textView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		
		textView.delegate = self
		
		textView.text = "\(deviceName): "
		
		currentCommandStartIndex = textView.text.endIndex
		
		textView.autocorrectionType = .no
		textView.smartDashesType = .no
		textView.smartQuotesType = .no
		textView.autocapitalizationType = .none
		textView.spellCheckingType = .no
		
		textView.indicatorStyle = .white
		
		textView.textDragDelegate = self
		textView.textDropDelegate = self
        
		keyboardObserver.observe { (state) in
			
			let rect = self.textView.convert(state.keyboardFrameEnd, from: nil).intersection(self.textView.bounds)
			
			UIView.animate(withDuration: state.duration, delay: 0.0, options: state.options, animations: {
				
				self.textView.contentInset.bottom = rect.height
				self.textView.scrollIndicatorInsets.bottom = rect.height
				
			}, completion: nil)
			
		}
        
        updateAppearanceFromSettings()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAppearanceFromSettingsAnimated), name: .appearanceDidChange, object: nil)
		
	}
	
    @objc
	func updateAppearanceFromSettingsAnimated() {
		
		UIView.animate(withDuration: 0.35) {
		
			self.updateAppearanceFromSettings()
			
		}
        
    }
	
	func updateAppearanceFromSettings() {

		let userDefaultsController = UserDefaultsController.shared
		
		let terminalFontSize = userDefaultsController.terminalFontSize
		self.textView.font = UIFont(name: "Menlo", size: CGFloat(terminalFontSize))
		
		let terminaltextColor = userDefaultsController.terminalTextColor
		self.textView.textColor = terminaltextColor
		self.textView.tintColor = terminaltextColor
		
		self.textView.backgroundColor = userDefaultsController.terminalBackgroundColor
		
		if userDefaultsController.userDarkKeyboardInTerminal {
			textView.keyboardAppearance = .dark
		} else {
			textView.keyboardAppearance = .light
		}
		
	}
	
	func clearScreen() {
		
		currentCommandStartIndex = nil
		textView.text = "\(deviceName): "
		currentCommandStartIndex = textView.text.endIndex
		
	}
	
	@discardableResult
	override func becomeFirstResponder() -> Bool {
		return textView.becomeFirstResponder()
	}

	var currentCommand: String {
		get {
			
			guard let currentCommandStartIndex = currentCommandStartIndex else {
				return ""
			}
			
			let currentCmdRange = currentCommandStartIndex..<textView.text.endIndex
			
			return String(textView.text[currentCmdRange])
		}
		set {
			
			if let currentCommandStartIndex = currentCommandStartIndex {
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
		
		let i = textView.text.distance(from: textView.text.startIndex, to: currentCommandStartIndex)
		
		if range.location < i {
			return false
		}
		
		if text == "\n" {
			
			if let processor = processor {
				
				let input = textView.text[currentCommandStartIndex..<textView.text.endIndex]
				
				if !input.isEmpty {
					delegate?.didEnterCommand(String(input))
				}

				if input == "clear" {
					
					clearScreen()

					return false
					
				} else {
					
					let output = processor.process(command: String(input))
                    let outputParsed = output.replacingOccurrences(of: DocumentManager.shared.activeDocumentsFolderURL.path, with: "~")
                    // Sometimes, fileManager adds /private in front of the directory
                    let outputParsed2 = outputParsed.replacingOccurrences(of: "/private", with: "")
					if !outputParsed2.isEmpty {
						textView.text = textView.text + "\n\(outputParsed2)"
					}
					
				}
				
			}
			
			textView.text = textView.text + "\n\(deviceName): "
			currentCommandStartIndex = textView.text.endIndex
			return false
		}
		
		return true
	}
	
	func textViewDidChange(_ textView: UITextView) {
				
	}
	
}

extension TerminalView {
    func clearBuffer() {
        currentCommandStartIndex = nil
        textView.text = "\(deviceName): "
        currentCommandStartIndex = textView.text.endIndex
    }
}
