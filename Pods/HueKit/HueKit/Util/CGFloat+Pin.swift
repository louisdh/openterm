//
//  CGFloat+Pin.swift
//  HueKit
//
//  Created by Louis D'hauwe on 02/08/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGFloat {
	
	func pinned(between minValue: CGFloat, and maxValue: CGFloat) -> CGFloat {
		
		if self < minValue {
			return minValue
		} else if self > maxValue {
			return maxValue
		} else {
			return self
		}
	}
	
}
