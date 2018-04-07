//
//  CustomTextView.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 03/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextView: UITextView {

	@IBInspectable
	var placeholder: String = "" {
		didSet {
			placeholderLabel.text = placeholder
		}
	}
	
	override var font: UIFont? {
		didSet {
			placeholderLabel.font = self.font
		}
	}
	
	override var text: String! {
		didSet {
			textDidChange()
		}
	}
	
	@objc
	private func textDidChange() {
		
		if text == nil || text.isEmpty {
			placeholderLabel.isHidden = false
		} else {
			placeholderLabel.isHidden = true
		}
		
	}

	let placeholderLabel = UILabel()
	
	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer	)
	
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		setup()
	}
	
	private func setup() {
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.textDidChange), name: .UITextViewTextDidChange, object: nil)
		
		placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
		placeholderLabel.textColor = .lightGray
		placeholderLabel.font = self.font
		
		self.addSubview(placeholderLabel)
		
		NSLayoutConstraint.activate([
			placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 6.0),
			placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8.0),
			placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8.0),
			placeholderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8.0)
		])
		
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.layer.cornerRadius = 5.0
		self.layer.masksToBounds = true
		
	}
	
}
