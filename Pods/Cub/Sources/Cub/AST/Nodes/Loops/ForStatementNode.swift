//
//  ForStatementNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 13/11/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct ForStatementNode: LoopNode {

	public let assignment: AssignmentNode
	public let condition: ASTNode
	public let interval: ASTNode

	public let body: BodyNode

	public let range: Range<Int>?

	public init(assignment: AssignmentNode, condition: ASTNode, interval: ASTNode, body: BodyNode, range: Range<Int>?) throws {

		self.assignment = assignment
		self.condition = condition
		self.interval = interval

		self.body = body
		self.range = range
		
		guard condition.isValidConditionNode else {
			throw compileError(.unexpectedCommand)
		}
		
		guard interval is AssignmentNode else {
			throw compileError(.unexpectedCommand)
		}
	}

	func compileLoop(with ctx: BytecodeCompiler, scopeStart: Int) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		let assignInstructions = try assignment.compile(with: ctx, in: self)
		bytecode.append(contentsOf: assignInstructions)

		// Interval

		let skipFirstIntervalLabel = ctx.nextIndexLabel()

		let startOfLoopLabel = ctx.peekNextIndexLabel()

		let intervalInstructions = try interval.compile(with: ctx, in: self)

		let skippedIntervalLabel = ctx.peekNextIndexLabel()

		ctx.pushLoopContinue(startOfLoopLabel)

		let skipFirstInterval = BytecodeInstruction(label: skipFirstIntervalLabel, type: .goto, arguments: [.index(skippedIntervalLabel)], comment: "skip first interval", range: range)
		bytecode.append(skipFirstInterval)

		bytecode.append(contentsOf: intervalInstructions)

		// Condition

		let conditionInstruction = try condition.compile(with: ctx, in: self)
		bytecode.append(contentsOf: conditionInstruction)

		let ifeqLabel = ctx.nextIndexLabel()

		let bodyBytecode = try body.compile(with: ctx, in: self)

		let goToEndLabel = ctx.nextIndexLabel()

		let peekNextLabel = ctx.peekNextIndexLabel()
		let ifeq = BytecodeInstruction(label: ifeqLabel, type: .ifFalse, arguments: [.index(peekNextLabel)], range: range)

		bytecode.append(ifeq)
		bytecode.append(contentsOf: bodyBytecode)

		let goToStart = BytecodeInstruction(label: goToEndLabel, type: .goto, arguments: [.index(startOfLoopLabel)], comment: "go to start of loop", range: range)
		bytecode.append(goToStart)

		// End of loop

		guard let _ = ctx.popLoopContinue() else {
			throw compileError(.unexpectedCommand)
		}

		return bytecode

	}

	public var childNodes: [ASTNode] {
		return [assignment, condition, interval, body]
	}

	public var description: String {

		var str = "ForStatementNode(assignment: \(assignment), "

		str += "condition: \n\(condition.description)"

		str += "interval: \n\(interval.description)"

		str += "body: \n\(body.description)"

		str += ")"

		return str
	}

	public var nodeDescription: String? {
		return "for"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		var children = [ASTChildNode]()

		let assignmentChildNode = ASTChildNode(connectionToParent: "assignment", isConnectionConditional: false, node: assignment)
		children.append(assignmentChildNode)

		let conditionChildNode = ASTChildNode(connectionToParent: "condition", isConnectionConditional: false, node: condition)
		children.append(conditionChildNode)

		let intervalChildNode = ASTChildNode(connectionToParent: "interval", isConnectionConditional: false, node: interval)
		children.append(intervalChildNode)

		let bodyChildNode = ASTChildNode(connectionToParent: nil, isConnectionConditional: true, node: body)
		children.append(bodyChildNode)

		return children
	}

}
