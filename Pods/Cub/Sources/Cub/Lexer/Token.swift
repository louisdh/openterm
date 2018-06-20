//
//  Token.swift
//  Cub
//
//  Created by Louis D'hauwe on 11/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct Token: CustomStringConvertible, Equatable {

	/// The token's type
	public let type: TokenType

	/// The range of the token in the original source code.
	/// The indices of this range are in terms of Swift characters.
	public let range: Range<Int>?

	public init(type: TokenType, range: Range<Int>? = nil) {
		self.type = type
		self.range = range
	}

	public var description: String {
		if let range = range {
			return "\(type) (\(range))"
		}
		return "\(type))"
	}

}
