//
//  FunctionNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct FunctionNode: ASTNode {

	public let prototype: FunctionPrototypeNode
	public let body: BodyNode

	public init(prototype: FunctionPrototypeNode, body: BodyNode) {
		self.prototype = prototype
		self.body = body
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		ctx.enterNewScope()

		let headerIndex = ctx.nextIndexLabel()
		let functionId = ctx.getFunctionId(for: self)
		let exitId = try ctx.getExitScopeFunctionId(for: self)

		let headerComment = "\(prototype.name)(\(prototype.argumentNames.joined(separator: ", ")))"

		let headerInstruction = BytecodeInstruction(label: headerIndex, type: .virtualHeader, arguments: [.index(functionId)], comment: headerComment)

		bytecode.append(headerInstruction)

		let skipExitInstrLabel = ctx.nextIndexLabel()

		let cleanupFunctionCallInstrLabel = ctx.nextIndexLabel()

		let exitFunctionInstrLabel = ctx.nextIndexLabel()

		ctx.pushFunctionExit(cleanupFunctionCallInstrLabel)

		let compiledFunction = try compileFunction(with: ctx)

		let exitHeaderLabel = ctx.nextIndexLabel()

		let exitHeaderInstruction = BytecodeInstruction(label: exitHeaderLabel, type: .privateVirtualHeader, arguments: [.index(exitId)], comment: "cleanup_\(prototype.name)")

		ctx.popFunctionExit()

		ctx.addCleanupRegistersToCurrentScope()
		let cleanupInstructions = ctx.cleanupRegisterInstructions()
		try ctx.leaveCurrentScope()

		let cleanupEndLabel = ctx.nextIndexLabel()

		let skipExitInstruction = BytecodeInstruction(label: skipExitInstrLabel, type: .skipPast, arguments: [.index(exitFunctionInstrLabel)], comment: "skip exit instruction")
		bytecode.append(skipExitInstruction)

		let invokeInstruction = BytecodeInstruction(label: cleanupFunctionCallInstrLabel, type: .invokeVirtual, arguments: [.index(exitId)], comment: "cleanup_\(prototype.name)()")
		bytecode.append(invokeInstruction)

		let exitFunctionInstruction = BytecodeInstruction(label: exitFunctionInstrLabel, type: .exitVirtual, comment: "exit function")
		bytecode.append(exitFunctionInstruction)

		bytecode.append(contentsOf: compiledFunction)

		// Cleanup

		bytecode.append(exitHeaderInstruction)
		bytecode.append(contentsOf: cleanupInstructions)

		bytecode.append(BytecodeInstruction(label: cleanupEndLabel, type: .privateVirtualEnd))

		//

		let endLabel = ctx.nextIndexLabel()
		bytecode.append(BytecodeInstruction(label: endLabel, type: .virtualEnd))

		return bytecode

	}

	private func compileFunction(with ctx: BytecodeCompiler) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		for arg in prototype.argumentNames.reversed() {

			let label = ctx.nextIndexLabel()
			let (varReg, _) = ctx.getRegister(for: arg)
			let instruction = BytecodeInstruction(label: label, type: .registerStore, arguments: [.index(varReg)], comment: "\(arg)")

			bytecode.append(instruction)

		}

		bytecode.append(contentsOf: try body.compile(with: ctx, in: self))

		if !prototype.returns {
			let returnNode = ReturnNode()
			bytecode.append(contentsOf: try returnNode.compile(with: ctx, in: self))
		}

		return bytecode

	}

	public var childNodes: [ASTNode] {
		return [prototype, body]
	}

	public var description: String {

		var str = "FunctionNode(prototype: \(prototype), "

		str += "\n    \(body.description)"

		return str + ")"
	}

	public var nodeDescription: String? {
		return "\(prototype.name)(\(prototype.argumentNames.joined(separator: ", ")))"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		var children = [ASTChildNode]()

		children.append(contentsOf: body.descriptionChildNodes)

		return children
	}

}
