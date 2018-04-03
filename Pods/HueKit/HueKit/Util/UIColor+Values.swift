//
//  UIColor+Values.swift
//  HueKit
//
//  Created by Louis D'hauwe on 02/08/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
	
	public var rgbValue: RGB? {
		
		guard let components = cgColor.components else {
			return nil
		}
		
		let numComponents = cgColor.numberOfComponents
		
		let r: CGFloat
		let g: CGFloat
		let b: CGFloat
		
		if numComponents < 3 {
			r = components[0]
			g = components[0]
			b = components[0]
		} else {
			r = components[0]
			g = components[1]
			b = components[2]
		}
		
		return RGB(r: r, g: g, b: b)
	}
	
	public var hsvValue: HSV? {
		
		guard let rgb = rgbValue else {
			return nil
		}
		
		return rgb.toHSV(preserveHS: true)
	}
	
	public func hsvValue(preservingHue hue: CGFloat, preservingSat sat: CGFloat) -> HSV? {

		guard let rgb = rgbValue else {
			return nil
		}
		
		return rgb.toHSV(preserveHS: true, h: hue, s: sat)
	}
	
}
