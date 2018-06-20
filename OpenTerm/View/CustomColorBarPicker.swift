//
//  CustomColorBarPicker.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 03/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import HueKit

@IBDesignable
class CustomColorBarPicker: ColorBarPicker {
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		colorBarView.layer.cornerRadius = 5.0
		colorBarView.layer.masksToBounds = true
	}
	
}
