//
//  NumberNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct NumberNode: ASTNode {

	public let value: NumberType
	public let range: Range<Int>?

	public init(value: NumberType, range: Range<Int>?) {
		self.value = value
		self.range = range
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		let i = self.value
		let label = ctx.nextIndexLabel()
		return [BytecodeInstruction(label: label, type: .pushConst, arguments: [.value(.number(i))], range: range)]

	}

	public var childNodes: [ASTNode] {
		return []
	}

	public var description: String {
		return "NumberNode(\(value))"
	}

	public var nodeDescription: String? {
		return "\(value)"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}

}
