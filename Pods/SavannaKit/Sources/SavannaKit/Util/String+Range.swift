//
//  String+Range.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 09/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

extension String {
	
	func nsRange(fromRange range: Range<Int>) -> NSRange {
		let from = range.lowerBound
		let to = range.upperBound
		
		return NSRange(location: from, length: to - from)
	}
	
}
