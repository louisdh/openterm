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
	public let range: Range<Int>?

	public init(variable: ASTNode, name: String, range: Range<Int>?) {
		self.variable = variable
		self.name = name
		self.range = range
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		var bytecode = BytecodeBody()

		bytecode.append(contentsOf: try variable.compile(with: ctx, in: self))

		guard let id = ctx.getStructMemberId(for: name) else {
			throw compileError(.unexpectedCommand)
		}

		let getInstr = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .structGet, arguments: [.index(id)], comment: "get \(name)", range: range)
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
