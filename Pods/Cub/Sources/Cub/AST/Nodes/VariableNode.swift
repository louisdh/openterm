//
//  VariableNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct VariableNode: ASTNode {

	public let name: String

	public init(name: String) {
		self.name = name
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		let (varReg, _) = ctx.getRegister(for: name)
		let load = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .registerLoad, arguments: [.index(varReg)], comment: name)

		bytecode.append(load)

		return bytecode

	}

	public var childNodes: [ASTNode] {
		return []
	}

	public var description: String {
		return "VariableNode(\(name))"
	}

	public var nodeDescription: String? {
		return "\(name)"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}

}
