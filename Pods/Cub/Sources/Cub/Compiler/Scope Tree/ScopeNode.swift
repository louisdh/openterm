//
//  ScopeNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 15/11/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

internal class ScopeNode {

	weak var parentNode: ScopeNode?
	var childNodes: [ScopeNode]

	var registerMap: [String: Int]
	var functionMap: [String: FunctionMapped]
	var internalRegisters: [Int]

	// TODO: make Set?
	// 0 = reg id
	// 1 = decompiled var name
	var registersToClean: [(Int, String?)]

	init(parentNode: ScopeNode? = nil, childNodes: [ScopeNode]) {
		self.parentNode = parentNode
		self.childNodes = childNodes
		registerMap = [String: Int]()
		functionMap = [String: FunctionMapped]()
		internalRegisters = [Int]()
		registersToClean = [(Int, String?)]()
	}

	func addRegistersToCleanToParent() {

		parentNode?.registersToClean.append(contentsOf: registersToClean)

	}

	/// Get deep register map (including parents' register map)
	func deepRegisterMap() -> [String: Int] {

		if let parentNode = parentNode {

			// Recursive

			var parentMap = parentNode.deepRegisterMap()

			registerMap.forEach {
				parentMap[$0.0] = $0.1
			}

			return parentMap
		}

		return registerMap
	}

	/// Get deep function map (including parents' function map)
	func deepFunctionMap() -> [String: FunctionMapped] {

		if let parentNode = parentNode {

			// Recursive

			var parentMap = parentNode.deepFunctionMap()

			functionMap.forEach {
				parentMap[$0.0] = $0.1
			}

			return parentMap
		}

		return functionMap
	}

}

struct FunctionMapped {

	let id: Int
	let exitId: Int
	let arguments: [String]
	let returns: Bool

}
