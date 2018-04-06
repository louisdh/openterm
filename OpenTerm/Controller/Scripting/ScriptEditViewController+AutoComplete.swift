//
//  ScriptEditViewController+AutoComplete.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 05/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import InputAssistant
import Cub

extension CubSyntaxAutoCompleteManager: InputAssistantViewDataSource {
	
	func textForEmptySuggestionsInInputAssistantView() -> String? {
		return nil
	}
	
	func numberOfSuggestionsInInputAssistantView() -> Int {
		return self.completions.count
	}
	
	func inputAssistantView(_ inputAssistantView: InputAssistantView, nameForSuggestionAtIndex index: Int) -> String {
		return self.completions[index].data.title
	}
}

// Make the input assistant reload when completions change
extension InputAssistantView: CubSyntaxAutoCompleteManagerDelegate {
	
}


protocol CubSyntaxAutoCompleteManagerDelegate: class {
	func autoCompleteManagerDidChangeCompletions()
}

protocol CubSyntaxAutoCompleteManagerDataSource: class {
	func completions() -> [CubSyntaxAutoCompleteManager.Completion]
}

class CubSyntaxAutoCompleteManager {
	
	struct Completion {
		/// Display name for the completion
		let name: String
		
		/// By default, a whitespace character will be inserted after the completion.
		let appendingSuffix: String
		
		/// Additional information to store in the completion
		let data: Cub.CompletionSuggestion
		
		init(_ name: String, data: Cub.CompletionSuggestion) {
			self.init(name, appendingSuffix: " ", data: data)
		}
		
		init(_ name: String, appendingSuffix: String, data: Cub.CompletionSuggestion) {
			self.name = name
			self.appendingSuffix = appendingSuffix
			self.data = data
		}
	}
	
	/// A set of completions to be displayed to the user.
	private(set) var completions: [Completion] = [] {
		didSet {
			self.delegate?.autoCompleteManagerDidChangeCompletions()
		}
	}
	
	/// Set this to receive notifications when state changes.
	weak var delegate: CubSyntaxAutoCompleteManagerDelegate?
	
	/// Set this to provide completions.
	weak var dataSource: CubSyntaxAutoCompleteManagerDataSource? {
		didSet {
			self.reloadData()
		}
	}
	
	/// Create a new auto complete manager. Starts in an empty state.
	init() {
		
	}
	
	func reloadData() {
		
		completions = dataSource?.completions() ?? []
	}
	
}
