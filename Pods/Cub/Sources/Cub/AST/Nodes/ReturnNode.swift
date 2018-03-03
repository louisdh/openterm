//
//  ReturnNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 17/12/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct ReturnNode: ASTNode {

	public let value: ASTNode?
	public let range: Range<Int>?

	init(value: ASTNode? = nil, range: Range<Int>?) {
		self.value = value
		self.range = range
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		if let value = value {

			let compiledValue = try value.compile(with: ctx, in: self)

			bytecode.append(contentsOf: compiledValue)

		}

		let label = ctx.nextIndexLabel()

		guard let cleanupLabel = ctx.peekFunctionExit() else {
			throw compileError(.unexpectedCommand)
		}

		let exitInstruction = BytecodeInstruction(label: label, type: .goto, arguments: [.index(cleanupLabel)], comment: "return", range: range)

		bytecode.append(exitInstruction)

		return bytecode
	}

	public var childNodes: [ASTNode] {
		return []
	}

	public var description: String {
		return "ReturnNode"
	}

	public var nodeDescription: String? {
		return "return"
	}

	public var descriptionChildNodes: [ASTChildNode] {

		if let value = value {
			return [ASTChildNode(node: value)]
		}

		return []
	}

}
