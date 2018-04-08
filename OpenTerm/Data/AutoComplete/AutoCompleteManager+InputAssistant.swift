//
//  AutoCompleteManager+InputAssistant.swift
//  OpenTerm
//
//  Created by Ian McDowell on 1/30/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import InputAssistant

// This file bridges the auto complete manager with the input assistant view.
// Using these extensions is optional, but provides a basic implementation for free.
// To use these, do the following:
// - Set the AutoCompleteManager's delegate to be the InputAssistantView
// - Set the InputAssistantView's data source to be the AutoCompleteManager

// Make the input assistant read its suggestions from the manager's completions
extension AutoCompleteManager: InputAssistantViewDataSource {

	func textForEmptySuggestionsInInputAssistantView() -> String? {
		return nil
	}

	func numberOfSuggestionsInInputAssistantView() -> Int {
		return self.completions.count
	}

	func inputAssistantView(_ inputAssistantView: InputAssistantView, nameForSuggestionAtIndex index: Int) -> String {
		return self.completions[index].name
	}
	
}

// Make the input assistant reload when completions change
extension InputAssistantView: AutoCompleteManagerDelegate {
	
	func autoCompleteManagerDidChangeState() {
		
	}

	func autoCompleteManagerDidChangeCompletions() {
		// Completions were updated, so display them.
		self.reloadData()
	}
	
}
