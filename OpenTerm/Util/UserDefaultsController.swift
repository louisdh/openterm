//
//  UserDefaultsController.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 20/01/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import UIKit

class UserDefaultsController {

	static let shared = UserDefaultsController(userDefaults: .standard)

	let userDefaults: UserDefaults

	init(userDefaults: UserDefaults) {
		self.userDefaults = userDefaults
	}

	var terminalTextColor: UIColor {
		get {
			return userDefaults.color(forKey: "terminalTextColor") ?? UIColor.defaultMainTintColor
		}
		set {
			userDefaults.set(newValue, forKey: "terminalTextColor")
			userDefaults.synchronize()
		}
	}

	var terminalBackgroundColor: UIColor {
		get {
			return userDefaults.color(forKey: "terminalBackgroundColor") ?? UIColor.panelBackgroundColor
		}
		set {
			userDefaults.set(newValue, forKey: "terminalBackgroundColor")
			userDefaults.synchronize()
		}
	}

	var terminalFontSize: Int {
		get {
			
			guard let val = userDefaults.object(forKey: "terminalFontSize") as? Int else {
				return 14
			}
			
			return val
		}
		set {
			userDefaults.set(newValue, forKey: "terminalFontSize")
			userDefaults.synchronize()
		}
	}

	var useDarkKeyboard: Bool {
		get {
			
			guard let val = userDefaults.object(forKey: "userDarkKeyboardInTerminal") as? Bool else {
				return true
			}
			
			return val
		}
		set {
			userDefaults.set(newValue, forKey: "userDarkKeyboardInTerminal")
			userDefaults.synchronize()
		}
	}

	var lastStoreReviewPrompt: Date? {
		get {
			return userDefaults.object(forKey: "lastStoreReviewPrompt") as? Date
		}
		set {
			userDefaults.set(newValue, forKey: "lastStoreReviewPrompt")
		}
	}
}
