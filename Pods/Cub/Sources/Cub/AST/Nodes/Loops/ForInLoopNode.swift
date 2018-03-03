//
//  ForInLoopNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 15/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct ForInLoopNode: LoopNode {

	public let iteratorVarNode: VariableNode

	public let arrayNode: ASTNode
	
	public let body: BodyNode
	
	public let range: Range<Int>?

	public init(iteratorVarNode: VariableNode, arrayNode: ASTNode, body: BodyNode, range: Range<Int>?) throws {
		
		self.iteratorVarNode = iteratorVarNode
		
		self.arrayNode = arrayNode
		
		self.body = body
		self.range = range
	}
	
	func compileLoop(with ctx: BytecodeCompiler, scopeStart: Int) throws -> BytecodeBody {
		
		var bytecode = BytecodeBody()
		
		let doStatementInstructions = try doStatementCompiled(with: ctx)
		bytecode.append(contentsOf: doStatementInstructions)
		
		return bytecode
		
	}
	
	// MARK: -
	
	private func doStatementCompiled(with ctx: BytecodeCompiler) throws -> BytecodeBody {
		
		var bytecode = BytecodeBody()
		
		let varReg = ctx.getNewInternalRegisterAndStoreInScope()
		
		let copiedArrayReg = ctx.getNewInternalRegisterAndStoreInScope()

		let arrayCountReg = ctx.getNewInternalRegisterAndStoreInScope()

		
		let assignInstructions = try assignmentInstructions(with: ctx, iteratorReg: varReg, arrayCopyReg: copiedArrayReg, arraySizeReg: arrayCountReg)
		bytecode.append(contentsOf: assignInstructions)

		// Interval
		
		let skipFirstIntervalLabel = ctx.nextIndexLabel()
		
		let startOfLoopLabel = ctx.peekNextIndexLabel()
		
		let intervalInstructions = try incrementInstructions(with: ctx, and: varReg)

		let skippedIntervalLabel = ctx.peekNextIndexLabel()
		
		ctx.pushLoopContinue(startOfLoopLabel)
		
		let skipFirstInterval = BytecodeInstruction(label: skipFirstIntervalLabel, type: .goto, arguments: [.index(skippedIntervalLabel)], comment: "skip first interval", range: range)
		bytecode.append(skipFirstInterval)
		
		bytecode.append(contentsOf: intervalInstructions)

		let conditionInstruction = try conditionInstructions(with: ctx, iteratorReg: varReg, sizeReg: arrayCountReg)
		bytecode.append(contentsOf: conditionInstruction)
		
		let ifeqLabel = ctx.nextIndexLabel()
		
		let (iVarReg, _) = ctx.getRegister(for: iteratorVarNode.name)


		var assignArrayValue = [BytecodeInstruction]()
		
		assignArrayValue.append(.init(label: ctx.nextIndexLabel(), type: .registerLoad, arguments: [.index(copiedArrayReg)], comment: "array", range: range))
		assignArrayValue.append(.init(label: ctx.nextIndexLabel(), type: .registerLoad, arguments: [.index(varReg)], comment: "index", range: range))
		
		assignArrayValue.append(.init(label: ctx.nextIndexLabel(), type: .arrayGet, comment: "array[i]", range: range))

		assignArrayValue.append(.init(label: ctx.nextIndexLabel(), type: .registerStore, arguments: [.index(iVarReg)], comment: "set var", range: range))

		
		let bodyBytecode = try body.compile(with: ctx, in: self)
		
		let goToEndLabel = ctx.nextIndexLabel()
		
		
		
		let peekNextLabel = ctx.peekNextIndexLabel()
		let ifeq = BytecodeInstruction(label: ifeqLabel, type: .ifFalse, arguments: [.index(peekNextLabel)], comment: "if false: exit loop", range: range)
		
		bytecode.append(ifeq)
		bytecode.append(contentsOf: assignArrayValue)
		bytecode.append(contentsOf: bodyBytecode)

		let goToStart = BytecodeInstruction(label: goToEndLabel, type: .goto, arguments: [.index(startOfLoopLabel)], comment: "loop", range: range)
		bytecode.append(goToStart)
		
		guard let _ = ctx.popLoopContinue() else {
			throw compileError(.unexpectedCommand)
		}
		
		return bytecode
	}
	
	private func assignmentInstructions(with ctx: BytecodeCompiler, iteratorReg: Int, arrayCopyReg: Int, arraySizeReg: Int) throws -> BytecodeBody {
		
		var bytecode = BytecodeBody()
		
		// Store copied array to reg
		// Get array from reg
		// Get array count
		// Store count to reg
		
		bytecode.append(contentsOf: try arrayNode.compile(with: ctx, in: self))
		
		bytecode.append(.init(label: ctx.nextIndexLabel(), type: .registerStore, arguments: [.index(arrayCopyReg)], comment: "array copy", range: range))

		bytecode.append(.init(label: ctx.nextIndexLabel(), type: .registerLoad, arguments: [.index(arrayCopyReg)], comment: "get copied array", range: range))


		bytecode.append(.init(label: ctx.nextIndexLabel(), type: .sizeOf, comment: "size of array", range: range))
		
		bytecode.append(.init(label: ctx.nextIndexLabel(), type: .registerStore, arguments: [.index(arraySizeReg)], comment: "array size", range: range))

		
		let iteratorStartInstr = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .pushConst, arguments: [.value(.number(0.0))], comment: "i = 0", range: range)
		bytecode.append(iteratorStartInstr)

		let instruction = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .registerStore, arguments: [.index(iteratorReg)], comment: "for in iterator", range: range)
		bytecode.append(instruction)
		
		return bytecode
		
	}
	
	private func conditionInstructions(with ctx: BytecodeCompiler, iteratorReg: Int, sizeReg: Int) throws -> BytecodeBody {
		
		let varNode = InternalVariableNode(register: iteratorReg, debugName: "iterator", range: range)
		let sizeNode = InternalVariableNode(register: sizeReg, debugName: "size", range: range)
		
		let conditionNode = try BinaryOpNode(op: "<", lhs: varNode, rhs: sizeNode, range: range)
		
		let bytecode = try conditionNode.compile(with: ctx, in: self)
		
		return bytecode
		
	}
	
	private func incrementInstructions(with ctx: BytecodeCompiler, and regName: Int) throws -> BytecodeBody {
		
		let varNode = InternalVariableNode(register: regName, debugName: "do repeat iterator", range: range)
		let decrementNode = try BinaryOpNode(op: "+", lhs: varNode, rhs: NumberNode(value: 1.0, range: range), range: range)
		
		let v = try decrementNode.compile(with: ctx, in: self)
		
		var bytecode = BytecodeBody()
		
		bytecode.append(contentsOf: v)
		
		let label = ctx.nextIndexLabel()
		let instruction = BytecodeInstruction(label: label, type: .registerStore, arguments: [.index(regName)], comment: "do repeat iterator", range: range)
		
		bytecode.append(instruction)
		
		return bytecode
		
	}
	
	public var childNodes: [ASTNode] {
		return [arrayNode, body]
	}
	
	public var description: String {
		
		var str = "ForInLoopNode(arrayNode: \(arrayNode), "
		
		str += "body: \n\(body.description)"
		
		str += ")"
		
		return str
	}
	
	public var nodeDescription: String? {
		return "for in"
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		var children = [ASTChildNode]()
		
		let arrayChildNode = ASTChildNode(connectionToParent: "arrayNode", isConnectionConditional: false, node: arrayNode)
		children.append(arrayChildNode)
		
		let bodyChildNode = ASTChildNode(connectionToParent: nil, isConnectionConditional: true, node: body)
		children.append(bodyChildNode)
		
		return children
	}
	
}
