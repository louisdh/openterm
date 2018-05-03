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
	public let range: Range<Int>?
	
	public init(name: String, range: Range<Int>?) {
		self.name = name
		self.range = range
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		let (varReg, isNew) = ctx.getRegister(for: name)
		
		guard !isNew else {
			throw compileError(.variableNotFound(name))
		}
		
		let load = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .registerLoad, arguments: [.index(varReg)], comment: name, range: range)

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
