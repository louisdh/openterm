//
//  StructNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 09/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public struct StructNode: ASTNode {

	public let prototype: StructPrototypeNode

	public let range: Range<Int>?

	init(prototype: StructPrototypeNode, range: Range<Int>?) {
		self.prototype = prototype
		self.range = range
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		let structId = ctx.getStructId(for: self)

		let headerLabel = ctx.nextIndexLabel()

		let headerComment = "\(prototype.name)(\(prototype.members.joined(separator: ", ")))"
		let header = BytecodeInstruction(label: headerLabel, type: .virtualHeader, arguments: [.index(structId)], comment: headerComment, range: range)
		bytecode.append(header)

		let initInstr = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .structInit, comment: "init \(prototype.name)", range: range)
		bytecode.append(initInstr)

		for member in prototype.members.reversed() {

			guard let id = ctx.getStructMemberId(for: member) else {
				throw compileError(.unexpectedCommand)
			}

			let instr = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .structSet, arguments: [.index(id)], comment: "set \(member)", range: range)
			bytecode.append(instr)

		}

		bytecode.append(BytecodeInstruction(label: ctx.nextIndexLabel(), type: .virtualEnd, range: range))

		return bytecode

	}

	public var childNodes: [ASTNode] {
		return [prototype]
	}

	public var description: String {
		return "StructNode(prototype: \(prototype))"
	}

	public var nodeDescription: String? {
		return "Struct"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}

}
