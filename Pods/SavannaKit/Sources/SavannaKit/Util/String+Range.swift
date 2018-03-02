//
//  String+Range.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 09/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

extension String {
	
	func nsRange(fromRange range: Range<Index>) -> NSRange? {
		
		// Convert positions to utf16, so emoticons are correctly supported.
		
		guard let start = range.lowerBound.samePosition(in: utf16) else {
			return nil
		}
		
		guard let end = range.upperBound.samePosition(in: utf16) else {
			return nil
		}
		
		return NSRange(location: utf16.distance(from: utf16.startIndex, to: start), length: utf16.distance(from: start, to: end))
	}
	
	func nsRange(fromRange range: Range<Int>) -> NSRange? {
		
		let start = self.index(startIndex, offsetBy: range.lowerBound)
		let end = self.index(startIndex, offsetBy: range.upperBound)

		let indexRange = start..<end
		
		return nsRange(fromRange: indexRange)
	}

}
