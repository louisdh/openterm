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
	
	func registerDefaults() {
		
		userDefaults.register(defaults: [
			"terminalFontSize" : 14,
			"terminalTextColor": NSKeyedArchiver.archivedData(withRootObject: UIColor.defaultMainTintColor),
			"terminalBackgroundColor": NSKeyedArchiver.archivedData(withRootObject: UIColor.panelBackgroundColor),
			"userDarkKeyboardInTerminal": true])
		
	}
	
	var terminalTextColor: UIColor? {
		get {
			if let val = userDefaults.color(forKey: "terminalTextColor") {
				return val
			}
			
			return nil
		}
		set {
			userDefaults.set(newValue, forKey: "terminalTextColor")
			userDefaults.synchronize()
		}
	}
	
	var terminalBackgroundColor: UIColor? {
		get {
			if let val = userDefaults.color(forKey: "terminalBackgroundColor") {
				return val
			}
			
			return nil
		}
		set {
			userDefaults.set(newValue, forKey: "terminalBackgroundColor")
			userDefaults.synchronize()
		}
	}
	
	var terminalFontSize: Int {
		get {
			let val = userDefaults.integer(forKey: "terminalFontSize")
			
			return val
		}
		set {
			userDefaults.set(newValue, forKey: "terminalFontSize")
			userDefaults.synchronize()
		}
	}
	
	var userDarkKeyboardInTerminal: Bool {
		get {
			let val = userDefaults.bool(forKey: "userDarkKeyboardInTerminal")
			
			return val
		}
		set {
			userDefaults.set(newValue, forKey: "userDarkKeyboardInTerminal")
			userDefaults.synchronize()
		}
	}
	
}
