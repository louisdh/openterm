//
//  InternalVariableNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 17/11/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct InternalVariableNode: ASTNode {

	public let register: Int
	public let debugName: String?

	public init(register: Int, debugName: String? = nil) {
		self.register = register
		self.debugName = debugName
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		let load = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .registerLoad, arguments: [.index(register)], comment: debugName)

		bytecode.append(load)

		return bytecode

	}

	public var childNodes: [ASTNode] {
		return []
	}

	public var description: String {
		return "InternalVariableNode(\(register))"
	}

	public var nodeDescription: String? {
		return "\(register)"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}

}
