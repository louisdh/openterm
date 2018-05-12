//
//  ConditionalStatementNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 16/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct ConditionalStatementNode: ASTNode {

	public let condition: ASTNode
	public let body: BodyNode
	public let elseBody: BodyNode?
	public let range: Range<Int>?

	public init(condition: ASTNode, body: BodyNode, elseBody: BodyNode? = nil, range: Range<Int>?) {
		self.condition = condition
		self.body = body
		self.elseBody = elseBody
		self.range = range
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		if condition is AssignmentNode {
			throw compileError(.assignmentAsCondition)
		}
		
		var bytecode = BytecodeBody()

		let conditionInstruction = try condition.compile(with: ctx, in: self)
		bytecode.append(contentsOf: conditionInstruction)

		let ifeqLabel = ctx.nextIndexLabel()

		var bodyBytecode = BytecodeBody()

		var elseBodyBytecode = BytecodeBody()

		let bodyInstructions = try body.compile(with: ctx, in: self)
		bodyBytecode.append(contentsOf: bodyInstructions)

		let goToEndLabel = ctx.nextIndexLabel()

		let peekNextLabel = ctx.peekNextIndexLabel()
		let ifeq = BytecodeInstruction(label: ifeqLabel, type: .ifFalse, arguments: [.index(peekNextLabel)], range: range)
		bytecode.append(ifeq)

		if let elseBody = elseBody {

			let instructions = try elseBody.compile(with: ctx, in: self)
			elseBodyBytecode.append(contentsOf: instructions)

		}

		bytecode.append(contentsOf: bodyBytecode)

		if let elseBody = elseBody, elseBody.nodes.count > 0 {
			let goToEnd = BytecodeInstruction(label: goToEndLabel, type: .goto, arguments: [.index(ctx.peekNextIndexLabel())], range: range)
			bytecode.append(goToEnd)
		}

		bytecode.append(contentsOf: elseBodyBytecode)

		return bytecode

	}

	public var childNodes: [ASTNode] {
		var children = [condition, body]

		if let elseBody = elseBody {
			children.append(elseBody)
		}

		return children
	}

	public var description: String {

		var str = "ConditionalStatementNode(condition: \(condition), body: ["

		str += "\n    \(body.description)"

		if let elseBody = elseBody {

			str += ", elseBody: "

			str += "\n    \(elseBody.description)"

			str += "\n)"

		} else {

			str += "\n])"

		}

		return str
	}

	public var nodeDescription: String? {
		return "if"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		var children = [ASTChildNode]()

		let conditionChildNode = ASTChildNode(connectionToParent: "condition", isConnectionConditional: false, node: condition)
		children.append(conditionChildNode)

		let ifChildNode = ASTChildNode(connectionToParent: "if", isConnectionConditional: true, node: body)
		children.append(ifChildNode)

		if let elseBody = elseBody {
			let elseChildNode = ASTChildNode(connectionToParent: "else", isConnectionConditional: true, node: elseBody)
			children.append(elseChildNode)
		}

		return children
	}

}
