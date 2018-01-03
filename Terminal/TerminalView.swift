//
//  TerminalView.swift
//  Terminal
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
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		textView.textColor = tintColor
	}
	
	private func setup() {
		
		textView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(textView)
		
		textView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		textView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		
		textView.backgroundColor = .clear
		
		textView.delegate = self
		
		textView.text = "\(deviceName): "
		
		currentCommandStartIndex = textView.text.endIndex
		
		textView.font = UIFont(name: "Menlo", size: 14.0)
		
		textView.textColor = tintColor
		
		textView.keyboardAppearance = .dark
		textView.autocorrectionType = .no
		textView.smartDashesType = .no
		textView.autocapitalizationType = .none
		textView.spellCheckingType = .no
		
		textView.indicatorStyle = .white
		
		keyboardObserver.observe { (state) in
			
			let rect = self.textView.convert(state.keyboardFrameEnd, from: nil).intersection(self.textView.bounds)
			
			UIView.animate(withDuration: state.duration, delay: 0.0, options: state.options, animations: {
				
				self.textView.contentInset.bottom = rect.height
				self.textView.scrollIndicatorInsets.bottom = rect.height
				
			}, completion: nil)
			
		}
		
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
				
				delegate?.didEnterCommand(String(input))

				if input == "clear" {
					
					currentCommandStartIndex = nil
					textView.text = "\(deviceName): "
					currentCommandStartIndex = textView.text.endIndex
					return false
					
				} else {
					
					let output = processor.process(command: String(input))
					if !output.isEmpty {
						textView.text = textView.text + "\n\(output)"
					}
					
				}
				
			}
			
			textView.text = textView.text + "\n\(deviceName): "
			currentCommandStartIndex = textView.text.endIndex
			return false
		}
		
		print(text)
		
		return true
	}
	
	func textViewDidChange(_ textView: UITextView) {
		
		print(textView.text)
		
	}
	
}
