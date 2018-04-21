//
//  CubDocumentationItemViewController.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 21/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import Cub

class CubDocumentationItemViewController: UIViewController {

	@IBOutlet weak var textView: UITextView!
	
	var item: DocumentationItem!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = item.title
		textView.attributedText = attributedString(item: item)
		textView.isEditable = false
		
		self.navigationController?.navigationBar.barStyle = .blackTranslucent
		self.view.backgroundColor = .panelBackgroundColor
		self.textView.backgroundColor = .panelBackgroundColor
		self.textView.textColor = .white
		
    }
	
	func attributedString(item: DocumentationItem) -> NSAttributedString {
		
		let font = UIFont.systemFont(ofSize: 17.0)
		
		let attributedString = NSMutableAttributedString(string: "", attributes: [.foregroundColor: UIColor.white, .font: font])
		
		let definitionAttrString = NSAttributedString(string: item.definition + "\n\n", attributes: [.font: UIFont(name: "Menlo-Regular", size: 17.0)!])
		
		attributedString.append(definitionAttrString)
		
		switch item.type {
		case .function:
			
			let descr: String
			
			if let functionDoc = item.functionDocumentation {
				descr = functionDoc.description ?? "No description"
			} else {
				descr = "No description"
			}
			
			let descrAttrString = NSAttributedString(string: descr + "\n", attributes: [.font: font])
			
			attributedString.append(descrAttrString)
			
			if let functionDoc = item.functionDocumentation {

				for arg in functionDoc.arguments {
					
					let argDescr: String
					
					if let argDescription = functionDoc.argumentDescriptions[arg] {
						argDescr = "\(arg): " + (argDescription ?? "No description")
					} else {
						argDescr = "\(arg): No description"
					}
					
					let argDescrAttrString = NSAttributedString(string: argDescr + "\n", attributes: [.font: font])
					
					attributedString.append(argDescrAttrString)
					
				}
				
				if let returnDescription = functionDoc.returnDescription {
					
					let returnsDescr = "Returns: " + returnDescription

					let returnsDescrAttrString = NSAttributedString(string: returnsDescr + "\n", attributes: [.font: font])
					
					attributedString.append(returnsDescrAttrString)
					
				}
				
			}
						
		case .variable:
			
			let descr: String
			
			if let variableDoc = item.variableDocumentation {
				descr = variableDoc.description ?? "No description"
			} else {
				descr = "No description"
			}
			
			let descrAttrString = NSAttributedString(string: descr + "\n", attributes: [.font: font])
			
			attributedString.append(descrAttrString)
			
		case .struct:
			
			let descr: String
			
			if let structDoc = item.structDocumentation {
				descr = structDoc.description ?? "No description"
			} else {
				descr = "No description"
			}
			
			let descrAttrString = NSAttributedString(string: descr + "\n", attributes: [.font: font])
			
			attributedString.append(descrAttrString)
			
			if let structDoc = item.structDocumentation {
				
				for member in structDoc.members {
					
					let memberDescr: String
					
					if let memberDescription = structDoc.memberDescriptions[member] {
						memberDescr = "\(member): " + (memberDescription ?? "No description")
					} else {
						memberDescr = "\(member): No description"
					}
					
					let memberDescrAttrString = NSAttributedString(string: memberDescr + "\n", attributes: [.font: font])
					
					attributedString.append(memberDescrAttrString)
					
				}
				
			}
			
		}
		
		return attributedString
	}

}

extension CubDocumentationItemViewController: StoryboardIdentifiable {
	
	static var storyboardIdentifier: String {
		return "CubDocumentationItemViewController"
	}
	
}
