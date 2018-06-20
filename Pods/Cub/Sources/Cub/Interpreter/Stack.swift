//
//  Stack.swift
//  Cub
//
//  Created by Louis D'hauwe on 20/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

/// LIFO stack
public struct Stack<Element>: CustomStringConvertible {

	private var items: [Element]
	private let limit: Int

	/// Manual stack size counting for performance
	private(set) var size: Int

	init(withLimit limit: Int) {
		self.limit = limit
		items = [Element]()
		items.reserveCapacity(limit)
		size = 0
	}

	var isEmpty: Bool {
		return size == 0
	}

	mutating func push(_ item: Element) throws {

		guard size < limit else {
			throw InterpreterError(type: .stackOverflow, range: nil)
		}

		items.append(item)
		size += 1
	}

	mutating func pop() throws -> Element {

		guard size > 0 else {
			throw InterpreterError(type: .illegalStackOperation, range: nil)
		}

		size -= 1

		return items.removeLast()
	}

	public var description: String {
		return items.description
	}

}
