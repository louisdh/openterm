//
//  ParseError.swift
//  Cub
//
//  Created by Louis D'hauwe on 22/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public protocol DisplayableError: Error {

	func description(inSource source: String) -> String

}

public struct ParseError: DisplayableError, CustomStringConvertible {

	/// The parse error type
	let type: ParseErrorType

	/// The range of the token in the original source code
	let range: Range<Int>?

	init(type: ParseErrorType, range: Range<Int>? = nil) {
		self.type = type
		self.range = range
	}

	public func description(inSource source: String) -> String {

		guard let startIndex = range?.lowerBound else {
			return type.description()
		}

		let lineNumber = source.lineNumber(of: startIndex)

		return type.description(atLine: lineNumber)
	}

	public var description: String {
		return "\(type)"
	}

}

extension String {

	func lineNumber(of index: Int) -> Int {

		let i = self.distance(from: self.startIndex, to: self.index(self.startIndex, offsetBy: index))

		let newLineIndices = self.indices(of: "\n").map { (index) -> Int in
			return self.distance(from: self.startIndex, to: index)
		}

		var lineNumber = 1

		for newLineIndex in newLineIndices {

			if i > newLineIndex {

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
