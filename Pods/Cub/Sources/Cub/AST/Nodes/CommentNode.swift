//
//  CommentNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 19/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct CommentNode: ASTNode {
	
	public let comment: String
	
	public let range: Range<Int>?
	
	public init(comment: String, range: Range<Int>?) {

		self.comment = comment
		self.range = range
		
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		
		return []
	}
	
	public var childNodes: [ASTNode] {
		return []
	}
	
	public var description: String {
		return "CommentNode(\(comment))"
	}
	
	public var nodeDescription: String? {
		return comment
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}
	
}
