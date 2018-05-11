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
		self.textView.attributedText = attributedString(item: item)
		self.textView.isEditable = false
		
		self.navigationController?.navigationBar.barStyle = .blackTranslucent
		self.view.backgroundColor = .panelBackgroundColor
		self.textView.backgroundColor = .panelBackgroundColor
		self.textView.textColor = .white
		self.textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		self.textView.indicatorStyle = .white
		
    }
	
	func attributedString(item: DocumentationItem) -> NSAttributedString {
		
		let font = UIFont.systemFont(ofSize: 17.0)
		let boldFont = UIFont.boldSystemFont(ofSize: 17.0)

		let titleFont = UIFont.systemFont(ofSize: 22, weight: .medium)

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.paragraphSpacingBefore = 16
		paragraphStyle.paragraphSpacing = 8

		let titleAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.white,
															 .font: titleFont,
															 .paragraphStyle: paragraphStyle]
		
		let attributedString = NSMutableAttributedString(string: "", attributes: [.foregroundColor: UIColor.white, .font: font])
		
		let definitionAttrString = NSAttributedString(string: item.definition + "\n", attributes: [.font: UIFont(name: "Menlo-Regular", size: 17.0)!])
		
		let declarationTitle = NSMutableAttributedString(string: "Declaration\n", attributes: titleAttributes)
		
		attributedString.append(declarationTitle)

		attributedString.append(definitionAttrString)
		
		switch item.type {
		case .function(let functionDocumentation):
			
			let overviewTitle = NSMutableAttributedString(string: "Overview\n", attributes: titleAttributes)
			
			attributedString.append(overviewTitle)
			
			let descr = functionDocumentation.description ?? "No description"
			
			let descrAttrString = NSAttributedString(string: descr + "\n", attributes: [.font: font])
			
			attributedString.append(descrAttrString)
			
			if !functionDocumentation.arguments.isEmpty {
				
				let argumentsTitle = NSMutableAttributedString(string: "Parameters\n", attributes: titleAttributes)
				
				attributedString.append(argumentsTitle)
				
				for arg in functionDocumentation.arguments {
					
					let argNameParagraphStyle = NSMutableParagraphStyle()
					argNameParagraphStyle.headIndent = 8
					argNameParagraphStyle.firstLineHeadIndent = 8
					
					let argNameAttrString = NSAttributedString(string: "\(arg)\n", attributes: [.font: boldFont,
																								  .paragraphStyle: argNameParagraphStyle])
					
					attributedString.append(argNameAttrString)
					
					let argDescrParagraphStyle = NSMutableParagraphStyle()
					argDescrParagraphStyle.headIndent = 16
					argDescrParagraphStyle.firstLineHeadIndent = 16
					
					let argDescr = (functionDocumentation.argumentDescriptions[arg] ?? "No description") + "\n"

					let argDescrAttrString = NSAttributedString(string: argDescr + "\n", attributes: [.font: font,
																									  .paragraphStyle: argDescrParagraphStyle])
					
					attributedString.append(argDescrAttrString)
					
				}
				
			}

			if functionDocumentation.returns {
				
				let returnValueTitle = NSMutableAttributedString(string: "Return value\n", attributes: titleAttributes)
				
				attributedString.append(returnValueTitle)
				
				let returnsDescr = functionDocumentation.returnDescription ?? "No description"
				
				let returnsDescrAttrString = NSAttributedString(string: returnsDescr + "\n", attributes: [.font: font])
				
				attributedString.append(returnsDescrAttrString)
				
			}
			
		case .variable(let variableDocumentation):
			
			let overviewTitle = NSMutableAttributedString(string: "Overview\n", attributes: titleAttributes)
			
			attributedString.append(overviewTitle)
			
			let descr = variableDocumentation.description ?? "No description"
			
			let descrAttrString = NSAttributedString(string: descr + "\n", attributes: [.font: font])
			
			attributedString.append(descrAttrString)
			
		case .struct(let structDocumentation):
			
			let overviewTitle = NSMutableAttributedString(string: "Overview\n", attributes: titleAttributes)
			
			attributedString.append(overviewTitle)
			
			let descr = structDocumentation.description ?? "No description"
			
			let descrAttrString = NSAttributedString(string: descr + "\n", attributes: [.font: font])
			
			attributedString.append(descrAttrString)
			
			let argumentsTitle = NSMutableAttributedString(string: "Parameters\n", attributes: titleAttributes)
			
			attributedString.append(argumentsTitle)
			
			for member in structDocumentation.members {
				
				let argNameParagraphStyle = NSMutableParagraphStyle()
				argNameParagraphStyle.headIndent = 8
				argNameParagraphStyle.firstLineHeadIndent = 8
				
				let argNameAttrString = NSAttributedString(string: "\(member)\n", attributes: [.font: boldFont,
																							.paragraphStyle: argNameParagraphStyle])
				
				attributedString.append(argNameAttrString)
				
				let argDescrParagraphStyle = NSMutableParagraphStyle()
				argDescrParagraphStyle.headIndent = 16
				argDescrParagraphStyle.firstLineHeadIndent = 16
				
				let argDescr = (structDocumentation.memberDescriptions[member] ?? "No description") + "\n"
				
				let argDescrAttrString = NSAttributedString(string: argDescr + "\n", attributes: [.font: font,
																								  .paragraphStyle: argDescrParagraphStyle])
				
				attributedString.append(argDescrAttrString)
				
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
