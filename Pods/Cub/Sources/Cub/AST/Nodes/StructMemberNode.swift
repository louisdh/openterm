//
//  StructMemberNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 09/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public struct StructMemberNode: ASTNode {

	public let variable: ASTNode
	public let name: String

	public init(variable: ASTNode, name: String) {
		self.variable = variable
		self.name = name
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		var bytecode = BytecodeBody()

		bytecode.append(contentsOf: try variable.compile(with: ctx, in: self))

		guard let id = ctx.getStructMemberId(for: name) else {
			throw CompileError.unexpectedCommand
		}

		let getInstr = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .structGet, arguments: [.index(id)], comment: "get \(name)")
		bytecode.append(getInstr)

		return bytecode
	}

	public var childNodes: [ASTNode] {
		return [variable]
	}

	public var description: String {
		return "StructMemberNode(\(variable.description).\(name))"
	}

	public var nodeDescription: String? {
		return "Struct Member"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}

}
