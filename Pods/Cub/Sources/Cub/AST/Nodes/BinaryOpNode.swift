//
//  BinaryOpNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct BinaryOpNode: ASTNode {

	public let range: Range<Int>?

	// TODO: add BinaryOpType enum
	
	static var opTypes: [String: BytecodeInstructionType] {
		return ["+": .add,
		        "-": .sub,
		        "*": .mul,
		        "/": .div,
		        "^": .pow,
		        "==": .eq,
		        "!=": .neq,
		        ">": .cmplt,
		        "<": .cmplt,
		        ">=": .cmple,
		        "<=": .cmple,
		        "&&": .and,
		        "||": .or,
		        "!": .not]
	}

	public let op: String
	public let opInstructionType: BytecodeInstructionType
	public let lhs: ASTNode

	/// Can be nil, e.g. for 'not' operation
	public let rhs: ASTNode?

	public init(op: String, lhs: ASTNode, rhs: ASTNode? = nil, range: Range<Int>?) throws {
		self.op = op
		self.range = range

		guard let type = BinaryOpNode.opTypes[op] else {
			throw BinaryOpNode.compileError(.unexpectedBinaryOperator, range: range)
		}

		self.opInstructionType = type

		self.lhs = lhs
		self.rhs = rhs
		
		guard lhs.isValidBinaryOpNode else {
			throw compileError(.unexpectedCommand)
		}
		
		if let rhs = rhs {
			guard rhs.isValidBinaryOpNode else {
				throw compileError(.unexpectedCommand)
			}
		}
		
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		if op == ">" || op == ">=" || op == "+" {

			// flip l and r

			let r = try rhs?.compile(with: ctx, in: self)
			let l = try lhs.compile(with: ctx, in: self)

			if let r = r {
				bytecode.append(contentsOf: r)
			}

			bytecode.append(contentsOf: l)

		} else {

			let l = try lhs.compile(with: ctx, in: self)
			let r = try rhs?.compile(with: ctx, in: self)

			bytecode.append(contentsOf: l)

			if let r = r {
				bytecode.append(contentsOf: r)
			}

		}

		let label = ctx.nextIndexLabel()
		
		let comment: String?
		
		if ctx.options.contains(.generateBytecodeComments) {
			comment = op
		} else {
			comment = nil
		}
		
		// FIXME: comment "op" is wrong for ">" and ">="
		let operation = BytecodeInstruction(label: label, type: opInstructionType, comment: comment, range: range)

		bytecode.append(operation)

		return bytecode
	}

	public var childNodes: [ASTNode] {
		if let rhs = rhs {
			return [lhs, rhs]
		}

		return [lhs]
	}

	public var description: String {
		return "BinaryOpNode(\(op), lhs: \(lhs), rhs: \(String(describing: rhs)))"
	}

	public var nodeDescription: String? {
		return op
	}

	public var descriptionChildNodes: [ASTChildNode] {
		let l = ASTChildNode(connectionToParent: "lhs", node: lhs)

		if let rhs = rhs {
			let r = ASTChildNode(connectionToParent: "rhs", node: rhs)
			return [l, r]
		}

		return [l]
	}

}
