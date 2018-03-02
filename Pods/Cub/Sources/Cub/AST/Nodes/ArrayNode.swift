//
//  ArrayNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 11/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct ArrayNode: ASTNode {
	
	public let values: [ASTNode]
	
	public init(values: [ASTNode]) throws {
		
		self.values = values
	}
	
	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		
		var bytecode = BytecodeBody()
		
		let initInstr = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .arrayInit, arguments: [.index(values.count)], comment: "init array")
		bytecode.append(initInstr)
		
		var i = 0

		for value in values {
			
			let valueBytecode = try value.compile(with: ctx, in: parent)
			bytecode.append(contentsOf: valueBytecode)

			let instr = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .arraySet, arguments: [.index(i)], comment: "set \(i)")
			bytecode.append(instr)
			
			i += 1
		}
		
		return bytecode
	}
	
	public var childNodes: [ASTNode] {
		return []
	}
	
	public var description: String {
		return "ArrayNode(values: \(values))"
	}
	
	public var nodeDescription: String? {
		return "Array"
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}
	
}
