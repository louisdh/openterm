//
//  UIColor+Hex.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 01/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

extension UIColor {
	
	public convenience init?(hexString: String) {
		
		guard hexString.hasPrefix("#") else {
			return nil
		}
		
		let start = hexString.index(hexString.startIndex, offsetBy: 1)
		let hexColor = String(hexString[start...])
		
		guard hexColor.count == 6 else {
			return nil
		}
		
		let scanner = Scanner(string: hexColor)
		var hexNumber: UInt64 = 0
		
		guard scanner.scanHexInt64(&hexNumber) else {
			return nil
		}
		
		let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
		let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
		let b = CGFloat((hexNumber & 0x0000ff)) / 255
		
		self.init(red: r, green: g, blue: b, alpha: 1.0)
	
	}
	
}
