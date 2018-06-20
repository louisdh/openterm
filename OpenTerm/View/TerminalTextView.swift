//
//  TerminalTextView.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/29/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

enum CaretStyle: Int {
	case verticalBar = 0
	case block = 1
	case underline = 2
	
	static var allCases: [CaretStyle] {
		return [.verticalBar, .block, .underline]
	}
}

/// UITextView that adopts the style of a terminal.
class TerminalTextView: UITextView {

	let autoCompleteLabel = UILabel()
	
	var autoCompletion: String = "" {
		didSet {
			autoCompleteLabel.text = autoCompletion
			update()
		}
	}
	
	var caretStyle: CaretStyle = .verticalBar
	
	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)

		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		setup()
	}

	private func setup() {
		
		self.addSubview(autoCompleteLabel)

		// Show characters such as ^C
		layoutManager.showsControlCharacters = true

		autocorrectionType = .no
		smartDashesType = .no
		smartQuotesType = .no
		autocapitalizationType = .none
		spellCheckingType = .no
		indicatorStyle = .white
		smartInsertDeleteType = .no
		
		updateAppearanceFromSettings()
		setCaretStyle()

		NotificationCenter.default.addObserver(self, selector: #selector(self.updateAppearanceFromSettingsAnimated), name: .appearanceDidChange, object: nil)
		
		let caDisplayLink = CADisplayLink(target: self, selector: #selector(update))
		caDisplayLink.add(to: .main, forMode: .commonModes)
		
		NotificationCenter.default.addObserver(self, selector: #selector(setCaretStyle), name: .caretStyleDidChange, object: nil)
	}
	
	@objc
	func setCaretStyle() {
		caretStyle = UserDefaultsController.shared.caretStyle
	}

	@objc
	private func update() {
		
		guard let rect = rectForAutoCompleteLabel() else {
			autoCompleteLabel.isHidden = true
			return
		}
		
		autoCompleteLabel.isHidden = false
		
		var frame = rect
		frame.origin.x = rect.maxX
		frame.size.width = self.bounds.width - frame.origin.x
		
		autoCompleteLabel.font = self.font
		autoCompleteLabel.textColor = self.textColor?.withAlphaComponent(0.5)
		
		autoCompleteLabel.frame = frame
	}
	
	func rectForAutoCompleteLabel() -> CGRect? {
		
		guard isFirstResponder else {
			return nil
		}
		
		guard let selectedTextRange = self.selectedTextRange else {
			return nil
		}
		
		let end = selectedTextRange.start
		
		guard let start = self.position(from: end, offset: -1) else {
			return nil
		}
		
		guard let range = self.textRange(from: start, to: end) else {
			return nil
		}
		
		let isOnEndOfLine: Bool
		
		let rect = self.firstRect(for: range)
		
		if let nextRangeEnd = self.position(from: end, offset: 1),
			let nextRange = self.textRange(from: end, to: nextRangeEnd) {
			
			let nextRect = self.firstRect(for: nextRange)
			
			isOnEndOfLine = nextRect.origin.y != rect.origin.y
			
		} else {
			isOnEndOfLine = true
		}
		
		guard isOnEndOfLine else {
			return nil
		}
		
		return rect
	}
	
	@objc
	private func updateAppearanceFromSettingsAnimated() {
		UIView.animate(withDuration: 0.35) {
			self.updateAppearanceFromSettings()
		}
	}

	private func updateAppearanceFromSettings() {
		let userDefaultsController = UserDefaultsController.shared

		let terminalFontSize = userDefaultsController.terminalFontSize
		self.font = UIFont(name: "Menlo", size: CGFloat(terminalFontSize))

		let terminaltextColor = userDefaultsController.terminalTextColor
		self.textColor = terminaltextColor
		self.tintColor = terminaltextColor

		self.backgroundColor = userDefaultsController.terminalBackgroundColor

		if userDefaultsController.useDarkKeyboard {
			self.keyboardAppearance = .dark
		} else {
			self.keyboardAppearance = .light
		}
	}
	
	override func caretRect(for position: UITextPosition) -> CGRect {
		var rect = super.caretRect(for: position)
		
		guard let font = self.font else {
			assertionFailure("Could not get font")
			return rect
		}
		
		switch caretStyle {
		case .verticalBar:
			return rect
			
		case .block:
			let dummyAtributedString = NSAttributedString(string: "X", attributes: [.font: font])
			let charWidth = dummyAtributedString.size().width
			
			rect.size.width = charWidth
			
		case .underline:
			let dummyAtributedString = NSAttributedString(string: "X", attributes: [.font: font])
			let charWidth = dummyAtributedString.size().width

			rect.origin.y += font.pointSize

			rect.size.height = rect.width
			rect.size.width = charWidth
		}
	
		return rect
	}
	
}
