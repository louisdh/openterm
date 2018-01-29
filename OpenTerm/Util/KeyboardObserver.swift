//
//  KeyboardObserver.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 09/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//
//  From: https://github.com/morizotter/KeyboardObserver

import Foundation
import UIKit

public enum KeyboardEventType {
	case willShow
	case didShow
	case willHide
	case didHide
	case willChangeFrame
	case didChangeFrame

	public var notificationName: Notification.Name {
		switch self {
		case .willShow:
			return .UIKeyboardWillShow
		case .didShow:
			return .UIKeyboardDidShow
		case .willHide:
			return .UIKeyboardWillHide
		case .didHide:
			return .UIKeyboardDidHide
		case .willChangeFrame:
			return .UIKeyboardWillChangeFrame
		case .didChangeFrame:
			return .UIKeyboardDidChangeFrame
		}
	}

	init?(name: Notification.Name) {
		switch name {
		case Notification.Name.UIKeyboardWillShow:
			self = .willShow
		case Notification.Name.UIKeyboardDidShow:
			self = .didShow
		case Notification.Name.UIKeyboardWillHide:
			self = .willHide
		case Notification.Name.UIKeyboardDidHide:
			self = .didHide
		case Notification.Name.UIKeyboardWillChangeFrame:
			self = .willChangeFrame
		case Notification.Name.UIKeyboardDidChangeFrame:
			self = .didChangeFrame
		default:
			return nil
		}
	}

	static var all: [KeyboardEventType] {
		return [.willShow,
				.didShow,
				.willHide,
				.didHide,
				.willChangeFrame,
				.didChangeFrame]
	}

	static var allEventNames: [Notification.Name] {
		return all.map { $0.notificationName }
	}
}

public struct KeyboardEvent {
	public let type: KeyboardEventType
	public let keyboardFrameBegin: CGRect
	public let keyboardFrameEnd: CGRect
	public let curve: UIViewAnimationCurve
	public let duration: TimeInterval
	public var isLocal: Bool?

	public var options: UIViewAnimationOptions {
		return UIViewAnimationOptions(rawValue: UInt(curve.rawValue))
	}

	init?(notification: Notification) {
		guard let userInfo = notification.userInfo else { return nil }
		guard let type = KeyboardEventType(name: notification.name) else { return nil }
		guard let begin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return nil }
		guard let end = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return nil }
		guard
			let curveInt = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
			let curve = UIViewAnimationCurve(rawValue: curveInt)
			else { return nil }
		guard
			let durationDouble = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
			else { return nil }

		self.type = type
		self.keyboardFrameBegin = begin
		self.keyboardFrameEnd = end
		self.curve = curve
		self.duration = TimeInterval(durationDouble)

		guard let isLocalInt = (userInfo[UIKeyboardIsLocalUserInfoKey] as? NSNumber)?.intValue else { return nil }
		self.isLocal = isLocalInt == 1

	}
}

public enum KeyboardState {
	case initial
	case showing
	case shown
	case hiding
	case hidden
	case changing
}

public typealias KeyboardEventClosure = ((_ event: KeyboardEvent) -> Void)

open class KeyboardObserver {
	open var state = KeyboardState.initial
	open var enabled = true
	fileprivate var eventClosures = [KeyboardEventClosure]()

	deinit {
		eventClosures.removeAll()
		KeyboardEventType.allEventNames.forEach {
			NotificationCenter.default.removeObserver(self, name: $0, object: nil)
		}
	}

	public init() {
		KeyboardEventType.allEventNames.forEach {
			NotificationCenter.default.addObserver(self, selector: #selector(notified(_:)), name: $0, object: nil)
		}
	}

	open func observe(_ event: @escaping KeyboardEventClosure) {
		eventClosures.append(event)
	}
}

internal extension KeyboardObserver {
	@objc func notified(_ notification: Notification) {
		guard let event = KeyboardEvent(notification: notification) else { return }

		switch event.type {
		case .willShow:
			state = .showing
		case .didShow:
			state = .shown
		case .willHide:
			state = .hiding
		case .didHide:
			state = .hidden
		case .willChangeFrame:
			state = .changing
		case .didChangeFrame:
			state = .shown
		}

		if !enabled { return }
		eventClosures.forEach { $0(event) }
	}
}
