//
//  BooleanNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 15/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct BooleanNode: ASTNode {

	/// Either 0 (false) or 1 (true)
	public let value: UInt8
	
	public let range: Range<Int>?

	public var boolValue: Bool {
		return value == 1
	}

	public init?(value: UInt8, range: Range<Int>?) {

		if value != 0 && value != 1 {
			return nil
		}

		self.value = value
		self.range = range

	}

	public init(bool: Bool, range: Range<Int>?) {

		if bool == true {

			self.value = 1

		} else {

			self.value = 0

		}
		
		self.range = range

	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		let label = ctx.nextIndexLabel()
		return [BytecodeInstruction(label: label, type: .pushConst, arguments: [.value(.bool(boolValue))], range: range)]

	}

	public var childNodes: [ASTNode] {
		return []
	}

	public var description: String {
		return "BooleanNode(\(value))"
	}

	public var nodeDescription: String? {
		if boolValue == true {
			return "true"
		} else {
			return "false"
		}
	}

	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}

}
