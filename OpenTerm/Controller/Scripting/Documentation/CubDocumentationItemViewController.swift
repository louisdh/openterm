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
		case .function(let functionDocumentation):
			
			let descr = functionDocumentation.description ?? "No description"
			
			let descrAttrString = NSAttributedString(string: descr + "\n", attributes: [.font: font])
			
			attributedString.append(descrAttrString)
			
			for arg in functionDocumentation.arguments {
				
				let argDescr: String
				
				if let argDescription = functionDocumentation.argumentDescriptions[arg] {
					argDescr = "\(arg): " + argDescription
				} else {
					argDescr = "\(arg): No description"
				}
				
				let argDescrAttrString = NSAttributedString(string: argDescr + "\n", attributes: [.font: font])
				
				attributedString.append(argDescrAttrString)
				
			}
			
			if let returnDescription = functionDocumentation.returnDescription {
				
				let returnsDescr = "Returns: " + returnDescription
				
				let returnsDescrAttrString = NSAttributedString(string: returnsDescr + "\n", attributes: [.font: font])
				
				attributedString.append(returnsDescrAttrString)
				
			}
			
		case .variable(let variableDocumentation):
			
			let descr = variableDocumentation.description ?? "No description"
			
			let descrAttrString = NSAttributedString(string: descr + "\n", attributes: [.font: font])
			
			attributedString.append(descrAttrString)
			
		case .struct(let structDocumentation):
			
			let descr = structDocumentation.description ?? "No description"
			
			let descrAttrString = NSAttributedString(string: descr + "\n", attributes: [.font: font])
			
			attributedString.append(descrAttrString)
			
			for member in structDocumentation.members {
				
				let memberDescr: String
				
				if let memberDescription = structDocumentation.memberDescriptions[member] {
					memberDescr = "\(member): " + (memberDescription ?? "No description")
				} else {
					memberDescr = "\(member): No description"
				}
				
				let memberDescrAttrString = NSAttributedString(string: memberDescr + "\n", attributes: [.font: font])
				
				attributedString.append(memberDescrAttrString)
				
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
