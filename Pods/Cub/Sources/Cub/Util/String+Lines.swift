//
//  String+Lines.swift
//  Cub
//
//  Created by Louis D'hauwe on 08/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

extension String {

	func getLine(_ index: Int, newLineIndices: [Int]) -> String {

		if self.isEmpty && index <= 1 {
			return ""
		}
		
		if self.hasSuffix("\n") && index == newLineIndices.count + 1 {
			return ""
		}
		
		let startI = newLineIndices[index - 1]
		
		let startIndex = self.index(self.startIndex, offsetBy: startI)
		
		if let endI = newLineIndices[safe: index] {
			
			let endIndex = self.index(self.startIndex, offsetBy: endI)
			
			#if os(Linux)
			var line = String(self[startIndex..<endIndex]) ?? ""
			#else
			var line = String(self[startIndex..<endIndex])
			#endif
			
			if line.hasPrefix("\n") {
				line.removeCharactersAtStart(1)
			}
			
			return line
			
		} else {
			
			#if os(Linux)
			var line = String(self[startIndex...]) ?? ""
			#else
			var line = String(self[startIndex...])
			#endif
			
			if line.hasPrefix("\n") {
				line.removeCharactersAtStart(1)
			}
			
			return line
		}
		
	}
	
	func getLine(_ index: Int) -> String {
		
		if self.isEmpty && index <= 1 {
			return ""
		}
		
		let newLineIndices = self.newLineIndices
		
		return getLine(index, newLineIndices: newLineIndices)
	}
	
	var newLineIndices: [Int] {
		return [0] + self.indices(of: "\n").map { (index) -> Int in
			return self.distance(from: self.startIndex, to: index)
		}
	}
	
	func lineNumber(of index: Int) -> Int {
		
		assert(index <= self.count, "Invalid index")
		
		let newLineIndices = self.indices(of: "\n").map { (index) -> Int in
			return self.distance(from: self.startIndex, to: index)
		}
		
		var lineNumber = 1
		
		for newLineIndex in newLineIndices {
			
			if index > newLineIndex {
				
				lineNumber += 1
				
			} else {
				
				break
				
			}
			
		}
		
		return lineNumber
	}
	
	func indices(of string: String, options: String.CompareOptions = .literal) -> [String.Index] {
		var result: [String.Index] = []
		var start = startIndex
		
		while let range = range(of: string, options: options, range: start..<endIndex) {
			result.append(range.lowerBound)
			start = range.upperBound
		}
		
		return result
	}
	
}
