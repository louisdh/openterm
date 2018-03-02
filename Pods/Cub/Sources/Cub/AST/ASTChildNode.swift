//
//  ASTChildNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 04/11/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct ASTChildNode {

	public let connectionToParent: String?
	public let isConnectionConditional: Bool

	public let node: ASTNode

	init(connectionToParent: String? = nil, isConnectionConditional: Bool = false, node: ASTNode) {

		self.connectionToParent = connectionToParent
		self.node = node
		self.isConnectionConditional = isConnectionConditional

	}

}
