//
//  ScriptMetadataViewController.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 03/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

enum ScriptMetadataState {
	case create
	case update
}

class ScriptMetadataViewController: UIViewController {

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var descriptionTextView: CustomTextView!
	@IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
	
	let keyboardObserver = KeyboardObserver()

	var state: ScriptMetadataState!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		nameTextField.delegate = self
		
		nameTextField.keyboardAppearance = UserDefaultsController.shared.useDarkKeyboard ? .dark : .light
		descriptionTextView.keyboardAppearance = UserDefaultsController.shared.useDarkKeyboard ? .dark : .light

		keyboardObserver.observe { [weak self] (state) in
			self?.adjustInsets(for: state)
		}
		
		guard let state = state else {
			return
		}
		
		switch state {
		case .create:
			saveBarButtonItem.title = "Create"
			
		case .update:
			saveBarButtonItem.title = "Save"

		}
		
		self.preferredContentSize = CGSize(width: 600, height: 344)
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if state == .create {
			
			nameTextField.becomeFirstResponder()
			
		}
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.view.endEditing(true)
		
	}
	
	private func adjustInsets(for state: KeyboardEvent) {
		
		let rect = self.scrollView.convert(state.keyboardFrameEnd, from: nil).intersection(self.scrollView.bounds)
		
		UIView.animate(withDuration: state.duration, delay: 0.0, options: state.options, animations: {
			
			if rect.height == 0 {
				
				// Keyboard is not visible.
				
				self.scrollView.contentInset.bottom = 0
				self.scrollView.scrollIndicatorInsets.bottom = 0
				
			} else {
				
				// Keyboard is visible, keyboard height includes safeAreaInsets.
				
				let bottomInset = rect.height - self.view.safeAreaInsets.bottom
				
				self.scrollView.contentInset.bottom = bottomInset
				self.scrollView.scrollIndicatorInsets.bottom = bottomInset
				
			}
			
		}, completion: nil)
		
	}
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		
		self.dismiss(animated: true, completion: nil)
		
	}
	
	@IBAction func save(_ sender: UIBarButtonItem) {
		
		self.dismiss(animated: true, completion: nil)

	}

}

extension ScriptMetadataViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
	
		if textField == nameTextField {
			descriptionTextView.becomeFirstResponder()
			
			// Return false so text view doesn't type new line.
			return false
		}
		
		return true
	}
	
}

extension ScriptMetadataViewController: StoryboardIdentifiable {
	
	static var storyboardIdentifier: String {
		return "ScriptMetadataViewController"
	}

}
