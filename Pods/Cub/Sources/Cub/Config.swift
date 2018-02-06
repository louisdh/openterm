//
//  Config.swift
//  Cub
//
//  Created by Louis D'hauwe on 06/05/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

#if NUMBER_TYPE_DECIMAL

	public typealias NumberType = Decimal
	
	extension Decimal {
		
		var intValue: Int {
			return NSDecimalNumber(decimal: self).intValue
		}
		
		init?(_ string: String) {
			
			if string == "-" || string == "e" || string == "." {
				return nil
			}
			
			let decNum = NSDecimalNumber(string: string)
			
			self = decNum.decimalValue
			
		}
		
	}

	/// Please note: can't raise to a decimal (`rhs` will be rounded down)
	func pow(_ lhs: Decimal, _ rhs: Decimal) -> Decimal {
		return pow(lhs, rhs.intValue)
	}

#else

	public typealias NumberType = Double

#endif

