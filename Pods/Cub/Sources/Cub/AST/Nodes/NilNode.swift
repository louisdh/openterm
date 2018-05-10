//
//  NilNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 06/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct NilNode: ASTNode {
	
	public let range: Range<Int>?
	
	public init(range: Range<Int>?) {
		self.range = range
	}
	
	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		
		let label = ctx.nextIndexLabel()
		return [BytecodeInstruction(label: label, type: .pushConst, arguments: [.value(.nil)], range: range)]
	}
	
	public var childNodes: [ASTNode] {
		return []
	}
	
	public var description: String {
		return "nil"
	}
	
	public var nodeDescription: String? {
		return "nil"
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}
	
}
