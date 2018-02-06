//
//  StoreReviewPrompter.swift
//  OpenTerm
//
//  Created by Ian McDowell on 2/3/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import StoreKit

class StoreReviewPrompter {

	static func promptIfNeeded() {
		if HistoryManager.history.count < 5 { return }
		guard let lastPrompt = UserDefaultsController.shared.lastStoreReviewPrompt else { return prompt() }
		let day: TimeInterval = 86400
		if Date().timeIntervalSince(lastPrompt) > day * 7 {
			prompt()
		}
	}

	private static func prompt() {
		SKStoreReviewController.requestReview()
		UserDefaultsController.shared.lastStoreReviewPrompt = Date()
	}
}
