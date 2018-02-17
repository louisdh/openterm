//
//  TerminalTextView.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/29/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

/// UITextView that adopts the style of a terminal.
class TerminalTextView: UITextView {

	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)

		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		setup()
	}

	private func setup() {

		// Show characters such as ^C
		layoutManager.showsControlCharacters = true

		autocorrectionType = .no
		smartDashesType = .no
		smartQuotesType = .no
		autocapitalizationType = .none
		spellCheckingType = .no

		indicatorStyle = .white

		updateAppearanceFromSettings()

		NotificationCenter.default.addObserver(self, selector: #selector(self.updateAppearanceFromSettingsAnimated), name: .appearanceDidChange, object: nil)
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

		if userDefaultsController.userDarkKeyboardInTerminal {
			self.keyboardAppearance = .dark
		} else {
			self.keyboardAppearance = .light
		}
	}
}
