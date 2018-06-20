//
//  CallNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

/// Either calls a function or the init of a struct
public struct CallNode: ASTNode {

	public let callee: String
	public let arguments: [ASTNode]
	public let range: Range<Int>?
	
	public init(callee: String, arguments: [ASTNode], range: Range<Int>?) {
		self.callee = callee
		self.arguments = arguments
		self.range = range
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		guard let id = try? ctx.getCallFunctionId(for: callee) else {
			throw compileError(.functionNotFound(callee))
		}

		guard let functionMapped = ctx.getMappedFunction(named: callee) else {
			throw compileError(.functionNotFound(callee))
		}
		
		guard arguments.count == functionMapped.arguments.count else {
			throw compileError(.incorrectNumberOfArgumentsToFunction(functionName: callee, expected: functionMapped.arguments.count, actual: arguments.count))
		}
		
		for arg in arguments {

			let argInstructions = try arg.compile(with: ctx, in: self)
			bytecode.append(contentsOf: argInstructions)

		}

		let invokeInstruction = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .invokeVirtual, arguments: [.index(id)], comment: "\(callee)", range: range)
		bytecode.append(invokeInstruction)

		if try isResultUnused(with: ctx, in: parent) {
			let popInstr = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .pop, comment: "pop unused function result", range: range)
			bytecode.append(popInstr)
		}

		return bytecode
	}

	private func isResultUnused(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> Bool {

		do {
			guard try ctx.doesFunctionReturn(for: callee) else {
				// No result
				return false
			}
		} catch {
			throw compileError(.functionNotFound(callee))
		}

		guard let parent = parent else {
			return true
		}

		let isResultUsed = parent is BinaryOpNode || parent is AssignmentNode || parent is ReturnNode || parent is ConditionalStatementNode || parent is CallNode

		return !isResultUsed

	}

	public var childNodes: [ASTNode] {
		return arguments
	}

	public var description: String {
		var str = "CallNode(name: \(callee), argument: "

		for a in arguments {
			str += "\n    \(a.description)"
		}

		return str + ")"
	}

	public var nodeDescription: String? {
		return callee
	}

	public var descriptionChildNodes: [ASTChildNode] {
		var children = [ASTChildNode]()

		for a in arguments {
			children.append(ASTChildNode(connectionToParent: "argument", node: a))
		}

		return children
	}

}
