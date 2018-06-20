//
//  ArraySubscriptNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 11/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct ArraySubscriptNode: ASTNode {
	
	public let variable: ASTNode
	public let name: ASTNode
	public let range: Range<Int>?

	public init(variable: ASTNode, name: ASTNode, range: Range<Int>?) {
		self.variable = variable
		self.name = name
		self.range = range
	}
	
	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		var bytecode = BytecodeBody()
		
		bytecode.append(contentsOf: try variable.compile(with: ctx, in: self))
		
		bytecode.append(contentsOf: try name.compile(with: ctx, in: self))
		
		let getInstr = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .arrayGet, comment: "get array", range: range)
		bytecode.append(getInstr)
		
		return bytecode
	}
	
	public var childNodes: [ASTNode] {
		return [variable]
	}
	
	public var description: String {
		return "ArraySubscriptNode(\(variable.description).\(name))"
	}
	
	public var nodeDescription: String? {
		return "Array Subscript"
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}
	
}
