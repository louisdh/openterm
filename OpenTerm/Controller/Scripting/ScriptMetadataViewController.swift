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
	case update(PridelandDocument)
}

protocol ScriptMetadataViewControllerDelegate: class {
	
	func didUpdateScript(_ updatedDocument: PridelandDocument)
	func didCreateScript(_ document: PridelandDocument)
	func didDeleteScript()
	
}

class ScriptMetadataViewController: UIViewController {

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var descriptionTextView: CustomTextView!
	@IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var colorBarPicker: CustomColorBarPicker!
	@IBOutlet weak var nameErrorLbl: UILabel!
	@IBOutlet weak var deleteBarButtonItem: UIBarButtonItem!
	
	weak var delegate: ScriptMetadataViewControllerDelegate?
	
	let keyboardObserver = KeyboardObserver()

	var state: ScriptMetadataState!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		nameTextField.delegate = self
		
		nameTextField.keyboardAppearance = UserDefaultsController.shared.useDarkKeyboard ? .dark : .light
		descriptionTextView.keyboardAppearance = UserDefaultsController.shared.useDarkKeyboard ? .dark : .light

		nameErrorLbl.isHidden = true
		
		keyboardObserver.observe { [weak self] (state) in
			self?.adjustInsets(for: state)
		}
		
		guard let state = state else {
			return
		}
		
		switch state {
		case .create:
			self.title = "New script"
			saveBarButtonItem.title = "Create"
			self.navigationItem.rightBarButtonItems = [saveBarButtonItem]
			
		case .update(let document):
			
			if let name = document.metadata?.name {
				self.title = "Edit “\(name)”"
			} else {
				self.title = "Edit ”\(document.fileURL.lastPathComponent)”"
			}
			
			saveBarButtonItem.title = "Save"
			nameTextField.text = document.metadata?.name ?? ""
			descriptionTextView.text = document.metadata?.description ?? ""
			colorBarPicker.hue = CGFloat(document.metadata?.hueTint ?? 0.0)
			deleteBarButtonItem.title = "Delete"
			deleteBarButtonItem.isEnabled = true
			deleteBarButtonItem.tintColor = .defaultMainTintColor
			
		}
		
		self.preferredContentSize = CGSize(width: 600, height: 344)
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		guard let state = state else {
			return
		}
		
		if case .create = state {
			
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
	
    @IBAction func deletePrideland(_ sender: UIBarButtonItem) {
        
        let metadata = self.metadata()
        
        let url = DocumentManager.shared.scriptsURL.appendingPathComponent("\(metadata.name).prideland")
		
		let deleteAlert = UIAlertController(title: "Are you sure you want to delete “\(metadata.name)”?", message: "This action can't be undone.", preferredStyle: .alert)
		
		deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (handler) in
			
			do {
				try DocumentManager.shared.fileManager.removeItem(at: url)
				
				self.dismiss(animated: true, completion: {
					self.delegate?.didDeleteScript()
				})
				
			} catch {
				self.showErrorAlert(error)
			}
			
		}))
		
		deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		self.present(deleteAlert, animated: true, completion: nil)
		
    }
	
	@IBAction func save(_ sender: UIBarButtonItem) {
		
		guard let state = state else {
			return
		}
		
		let name = nameTextField.text ?? ""

		guard !name.isEmpty else {
			validateName(name)
			return
		}
		
		let metadata = self.metadata()
		
		switch state {
		case .create:
			let url = DocumentManager.shared.scriptsURL.appendingPathComponent("\(metadata.name).prideland")
			
			let document = PridelandDocument(fileURL: url)
			document.metadata = metadata
			
			document.save(to: url, for: .forCreating) { (success) in
				
				if success {
					self.dismiss(animated: true, completion: nil)
					self.delegate?.didCreateScript(document)
				} else {
					self.showErrorAlert()
				}

			}
			
		case .update(let currentDocument):
			
			let prevMetadata = currentDocument.metadata
			
			currentDocument.metadata = metadata

			if prevMetadata?.name != metadata.name {
				
				// rename

				let url = DocumentManager.shared.scriptsURL.appendingPathComponent("\(metadata.name).prideland")

				currentDocument.save(to: url, for: .forCreating) { (success) in
					
					if success {
						self.dismiss(animated: true, completion: nil)
						self.delegate?.didUpdateScript(currentDocument)
					} else {
						self.showErrorAlert()
					}
					
				}
				
			} else {
				
				currentDocument.updateChangeCount(.done)
				delegate?.didUpdateScript(currentDocument)
				self.dismiss(animated: true, completion: nil)

			}

		}
		

	}
	
	private func metadata() -> PridelandMetadata {
		
		let name = nameTextField.text ?? ""
		let description = descriptionTextView.text ?? ""
		let hueTint = Double(colorBarPicker.hue)
		
		return PridelandMetadata(name: name, description: description, hueTint: hueTint)
	}

}

extension ScriptMetadataViewController: UITextFieldDelegate {

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		guard let currentText = textField.text else {
			return true
		}
		
		let newString = (currentText as NSString).replacingCharacters(in: range, with: string) as String
		
		validateName(newString)
		
		return true
	}
	
	func validateName(_ value: String) {
		
		if let error = nameValidationError(value) {
			
			nameErrorLbl.text = error
			nameErrorLbl.isHidden = false
			
		} else {
			
			nameErrorLbl.isHidden = true
			
		}
		
	}
	
	func nameValidationError(_ name: String) -> String? {
		
		guard let state = state else {
			return nil
		}
		
		if name.isEmpty {
			return "Command name is required."
		}
		
		if name.contains(" ") {
			return "Command name may not contain spaces."
		}
		
		let url: URL?
		
		switch state {
		case .create:
			url = nil
			
		case .update(let document):
			url = document.fileURL
			
		}
		
		let usedNames = allUsedScriptNames(ignoringURL: url)
		
		if usedNames.contains(name) {
			return "This command name is already used."
		}
		
		return nil
	}
	
	func allUsedScriptNames(ignoringURL: URL?) -> [String] {
		
		let fileManager = DocumentManager.shared.fileManager
		
		do {
			
			let documentsURLs = try fileManager.contentsOfDirectory(at: DocumentManager.shared.scriptsURL, includingPropertiesForKeys: [], options: .skipsPackageDescendants)
		
			let pridelandURLs = documentsURLs.filter({ $0 != ignoringURL && $0.pathExtension.lowercased() == "prideland" })
			
			return pridelandURLs.map({ ($0.lastPathComponent as NSString).deletingPathExtension })
			
		} catch {
			
			return []
		}
		
	}
	
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
