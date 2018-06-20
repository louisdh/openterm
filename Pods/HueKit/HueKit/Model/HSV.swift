//
//  HSV.swift
//  HueKit
//
//  Created by Louis D'hauwe on 02/08/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

public struct HSV {
	/// In degrees (range 0...360)
	public var h: CGFloat
	
	/// Percentage in range 0...1
	public var s: CGFloat
	
	/// Percentage in range 0...1
	/// Also known as "brightness" (B)
	public var v: CGFloat
}

extension HSV {
	
	/// These functions convert between an RGB value with components in the
	/// 0.0..1.0 range to HSV where Hue is 0 .. 360 and Saturation and
	/// Value (aka Brightness) are percentages expressed as 0.0..1.0.
	//
	/// Note that HSB (B = Brightness) and HSV (V = Value) are interchangeable
	/// names that mean the same thing. I use V here as it is unambiguous
	/// relative to the B in RGB, which is Blue.
	func toRGB() -> RGB {
		
		var rgb = self.hueToRGB()
		
		let c = v * s
		let m = v - c
		
		rgb.r = rgb.r * c + m
		rgb.g = rgb.g * c + m
		rgb.b = rgb.b * c + m
		
		return rgb
	}
	
	func hueToRGB() -> RGB {
		
		let hPrime = h / 60.0
		
		let x = 1.0 - abs(hPrime.truncatingRemainder(dividingBy: 2.0) - 1.0)
		
		let r: CGFloat
		let g: CGFloat
		let b: CGFloat
		
		if hPrime < 1.0 {
			
			r = 1
			g = x
			b = 0
			
		} else if hPrime < 2.0 {
			
			r = x
			g = 1
			b = 0
			
		} else if hPrime < 3.0 {
			
			r = 0
			g = 1
			b = x
			
		} else if hPrime < 4.0 {
			
			r = 0
			g = x
			b = 1
			
		} else if hPrime < 5.0 {
			
			r = x
			g = 0
			b = 1
			
		} else {
			
			r = 1
			g = 0
			b = x
			
		}
		
		return RGB(r: r, g: g, b: b)
	}
}
