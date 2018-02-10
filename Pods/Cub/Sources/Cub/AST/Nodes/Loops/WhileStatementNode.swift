//
//  WhileStatementNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 21/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public struct WhileStatementNode: LoopNode {

	public let condition: ASTNode
	public let body: BodyNode

	public init(condition: ASTNode, body: BodyNode) throws {

		guard condition.isValidConditionNode else {
			throw CompileError.unexpectedCommand
		}

		self.condition = condition
		self.body = body
	}

	func compileLoop(with ctx: BytecodeCompiler, scopeStart: Int) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		ctx.pushLoopContinue(scopeStart)

		let conditionInstruction = try condition.compile(with: ctx, in: self)
		bytecode.append(contentsOf: conditionInstruction)

		let ifeqLabel = ctx.nextIndexLabel()

		let bodyBytecode = try body.compile(with: ctx, in: self)

		let goToEndLabel = ctx.nextIndexLabel()

		let peekNextLabel = ctx.peekNextIndexLabel()
		let ifeq = BytecodeInstruction(label: ifeqLabel, type: .ifFalse, arguments: [.index(peekNextLabel)])

		bytecode.append(ifeq)
		bytecode.append(contentsOf: bodyBytecode)

		let goToStart = BytecodeInstruction(label: goToEndLabel, type: .goto, arguments: [.index(scopeStart)])
		bytecode.append(goToStart)

		guard let _ = ctx.popLoopContinue() else {
			throw CompileError.unexpectedCommand
		}

		return bytecode
	}

	public var childNodes: [ASTNode] {
		return [condition, body]
	}

	public var description: String {

		var str = "WhileStatementNode(condition: \(condition), body: "

		str += "\n    \(body.description)"

		str += ")"

		return str
	}

	public var nodeDescription: String? {
		return "while"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		var children = [ASTChildNode]()

		let conditionChildNode = ASTChildNode(connectionToParent: "condition", isConnectionConditional: false, node: condition)
		children.append(conditionChildNode)

		let bodyChildNode = ASTChildNode(connectionToParent: nil, isConnectionConditional: true, node: body)

		children.append(bodyChildNode)

		return children
	}

}
