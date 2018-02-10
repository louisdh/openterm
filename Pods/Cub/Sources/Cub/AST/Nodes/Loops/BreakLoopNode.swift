//
//  BreakLoopNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 08/12/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public struct BreakLoopNode: ASTNode {

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		let label = ctx.nextIndexLabel()

		guard let breakLabel = ctx.peekLoopHeader() else {
			throw CompileError.unexpectedCommand
		}

		return [BytecodeInstruction(label: label, type: .goto, arguments: [.index(breakLabel)], comment: "break")]

	}

	public var childNodes: [ASTNode] {
		return []
	}

	public var description: String {
		return "BreakLoopNode"
	}

	public var nodeDescription: String? {
		return "break"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}

}
