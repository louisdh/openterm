//
//  AssignmentNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 10/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

struct AssignmentNodeValidationError: Error {
	let invalidValueType: String
}

public struct AssignmentNode: ASTNode {

	public let variable: ASTNode
	public let value: ASTNode
	public let range: Range<Int>?
	public let documentation: String?

	public init(variable: ASTNode, value: ASTNode, range: Range<Int>?, documentation: String?) throws {

		guard value is NumberNode || value is VariableNode || value is StructMemberNode || value is CallNode || value is BinaryOpNode || value is StringNode || value is ArrayNode || value is ArraySubscriptNode || value is BooleanNode else {
			throw AssignmentNodeValidationError(invalidValueType: value.description)
		}

		self.variable = variable
		self.value = value
		self.range = range
		self.documentation = documentation
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		let v = try value.compile(with: ctx, in: self)

		var bytecode = BytecodeBody()

		bytecode.append(contentsOf: v)

		let label = ctx.nextIndexLabel()

		if let variable = variable as? VariableNode {

			let (varReg, isNew) = ctx.getRegister(for: variable.name)

			let type: BytecodeInstructionType = isNew ? .registerStore : .registerUpdate

			let instruction = BytecodeInstruction(label: label, type: type, arguments: [.index(varReg)], comment: "\(variable.name)", range: range)

			bytecode.append(instruction)

		} else if let member = variable as? StructMemberNode {

			let (members, varNode) = try getStructUpdate(member, members: [], with: ctx)

			let (varReg, isNew) = ctx.getRegister(for: varNode.name)

			guard !isNew else {
				throw compileError(.unexpectedCommand)
			}

			let varInstructions = try varNode.compile(with: ctx, in: self)
			bytecode.append(contentsOf: varInstructions)

			let membersMapped = members.map { InstructionArgumentType.index($0) }

			let instruction = BytecodeInstruction(label: label, type: .structUpdate, arguments: membersMapped, comment: "\(membersMapped)", range: range)

			bytecode.append(instruction)

			let storeInstruction = BytecodeInstruction(label: label, type: .registerUpdate, arguments: [.index(varReg)], comment: "\(varNode.name)", range: range)

			bytecode.append(storeInstruction)

		} else if let arraySubscript = variable as? ArraySubscriptNode {
			
			guard let variable = arraySubscript.variable as? VariableNode else {
				throw compileError(.unexpectedCommand)
			}
			
			bytecode.append(contentsOf: try arraySubscript.name.compile(with: ctx, in: self))
			
			bytecode.append(contentsOf: try variable.compile(with: ctx, in: self))

			let instr = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .arrayUpdate, comment: "update", range: range)
			bytecode.append(instr)
		
			let (varReg, isNew) = ctx.getRegister(for: variable.name)
			
			guard !isNew else {
				throw compileError(.unexpectedCommand)
			}
			
			let instruction = BytecodeInstruction(label: label, type: .registerUpdate, arguments: [.index(varReg)], comment: "\(variable.name)", range: range)
			
			bytecode.append(instruction)
			
		} else {
			// error
			
		}
		
		return bytecode

	}

	private func getStructUpdate(_ memberNode: StructMemberNode, members: [Int], with ctx: BytecodeCompiler) throws -> ([Int], VariableNode) {

		var members = members

		guard let memberId = ctx.getStructMemberId(for: memberNode.name) else {
			throw compileError(.unexpectedCommand)
		}

		members.append(memberId)

		if let varNode = memberNode.variable as? VariableNode {
			return (members, varNode)

		} else {

			guard let childMemberNode = memberNode.variable as? StructMemberNode else {
				throw compileError(.unexpectedCommand)
			}

			return try getStructUpdate(childMemberNode, members: members, with: ctx)

		}

	}

	public var childNodes: [ASTNode] {
		return [variable, value]
	}

	public var description: String {
		return "\(variable.description) = \(value.description)"
	}

	public var nodeDescription: String? {
		return "="
	}

	public var descriptionChildNodes: [ASTChildNode] {
		let lhs = ASTChildNode(connectionToParent: "lhs", node: variable)
		let rhs = ASTChildNode(connectionToParent: "rhs", node: value)

		return [lhs, rhs]
	}

}
