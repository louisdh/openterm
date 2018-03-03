//
//  ContinueNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 22/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct ContinueNode: ASTNode {

	public let range: Range<Int>?

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		let label = ctx.nextIndexLabel()

		guard let continueLabel = ctx.peekLoopContinue() else {
			throw compileError(.unexpectedCommand)
		}

		return [BytecodeInstruction(label: label, type: .goto, arguments: [.index(continueLabel)], comment: "continue", range: range)]

	}

	public var childNodes: [ASTNode] {
		return []
	}

	public var description: String {
		return "ContinueNode"
	}

	public var nodeDescription: String? {
		return "continue"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}

}
