//
//  StructPrototypeNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 10/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public struct StructPrototypeNode: ASTNode {

	public let name: String
	public let members: [String]

	public let range: Range<Int>?

	public init(name: String, members: [String], range: Range<Int>?) throws {

		self.name = name
		self.members = members
		self.range = range
		
		guard members.count > 0 else {
			throw compileError(.emptyStruct)
		}
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		return []
	}

	public var childNodes: [ASTNode] {
		return []
	}

	public var description: String {
		return "StructPrototypeNode(name: \(name), members: \(members))"
	}

	public var nodeDescription: String? {
		return "Struct Prototype"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}

}
