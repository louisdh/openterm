//
//  BodyNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 26/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

/// Body that defines a scope, `compile(with ctx)`.
public struct BodyNode: ASTNode {

	public let nodes: [ASTNode]
	public let range: Range<Int>?

	public init(nodes: [ASTNode], range: Range<Int>?) {
		self.nodes = nodes
		self.range = range
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		ctx.enterNewScope()

		var bytecode = BytecodeBody()

		for a in nodes {
			let instructions = try a.compile(with: ctx, in: self)
			bytecode.append(contentsOf: instructions)
		}

		try ctx.leaveCurrentScope()

		return bytecode

	}

	public var childNodes: [ASTNode] {
		return nodes
	}

	public var description: String {
		var str = ""

		for a in nodes {
			str += "\n    \(a.description)"
		}

		return str
	}

	public var nodeDescription: String? {
		return "body"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		var children = [ASTChildNode]()

		for a in nodes {
			children.append(ASTChildNode(node: a))
		}

		return children
	}
}
