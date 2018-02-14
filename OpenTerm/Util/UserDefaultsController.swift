//
//  UserDefaultsController.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 20/01/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import UIKit

extension UserDefaults {

	// These keys represent the values that OpenTerm saves in UserDefaults.
	// Their string representation is sent to UserDefaults.
	enum Key: String {
		case terminalFontSize
		case terminalTextColor
		case terminalBackgroundColor
		case useDarkKeyboardInTerminal
		case lastStoreReviewPrompt

		// If the key should have a default value, return that here.
		var defaultValue: Any? {
			switch self {
			case .terminalFontSize:
				return 14
			case .terminalTextColor:
				return NSKeyedArchiver.archivedData(withRootObject: UIColor.defaultMainTintColor)
			case .terminalBackgroundColor:
				return NSKeyedArchiver.archivedData(withRootObject: UIColor.panelBackgroundColor)
			case .useDarkKeyboardInTerminal:
				return true
			case .lastStoreReviewPrompt:
				return nil
			}
		}

		// Hopefully some newer version of swift adds this :(
		static let all: [Key] = [
			.terminalFontSize,
			.terminalTextColor,
			.terminalBackgroundColor,
			.useDarkKeyboardInTerminal
		]
	}

	/// User defaults for storing terminal preferences.
	/// When accessing this for the first time, the default values are registered.
	static let terminalDefaults: UserDefaults = {
		let defaults = UserDefaults.standard
		// Map each key to its default value, insert into a dictionary, then register those defaults.
		defaults.register(defaults: .init(uniqueKeysWithValues: UserDefaults.Key.all.flatMap { key in
			if let defaultValue = key.defaultValue {
				return (key.rawValue, defaultValue)
			} else {
				return nil
			}
		}))
		return defaults
	}()

	/// Access the value for the given key.
	/// When getting, the object will be force cast to whatever return type you tell the type system it will have.
	subscript<T> (key: Key) -> T {
		get {
			guard let value = self.object(forKey: key.rawValue) as? T else {
				fatalError("Invalid type for user default with key: \(key.rawValue).")
			}
			return value
		}
		set {
			self.set(newValue, forKey: key.rawValue)
		}
	}

}

// Color extensions. Use NSKeyedArchiver to store and retrieve colors in UserDefaults.
// To make sure the default subscript doesn't handle the value,
// both optional and non-optional UIColor subscripts are overridden.
extension UserDefaults {
	subscript(key: Key) -> UIColor? {
		get {
			guard
				let data = data(forKey: key.rawValue),
				let color = NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor
				else {
					return nil
			}
			return color
		}
		set {
			guard let value = newValue else {
				set(Any?.none, forKey: key.rawValue)
				return
			}

			let data = NSKeyedArchiver.archivedData(withRootObject: value)
			set(data, forKey: key.rawValue)
		}
	}
	subscript(key: Key) -> UIColor {
		get {
			guard let color: UIColor = self[key] else {
				fatalError("Unable to find color with key: \(key.rawValue)")
			}
			return color
		}
		set {
			let optionalValue: UIColor? = newValue
			self[key] = optionalValue
		}
	}
}
