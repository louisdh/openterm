//
//  StringNode.swift
//  Cub macOS Tests
//
//  Created by Louis D'hauwe on 03/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct StringNode: ASTNode {
	
	public let value: String
	public let range: Range<Int>?
	
	public init(value: String, range: Range<Int>?) {
		
		self.value = value
		self.range = range
	}
	
	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		
		let label = ctx.nextIndexLabel()
		return [BytecodeInstruction(label: label, type: .pushConst, arguments: [.value(.string(value))], range: range)]
		
	}
	
	public var childNodes: [ASTNode] {
		return []
	}
	
	public var description: String {
		return "StringNode(\(value))"
	}
	
	public var nodeDescription: String? {
		return value
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}
	
}
