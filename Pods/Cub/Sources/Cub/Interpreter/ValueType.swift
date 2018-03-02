//
//  ValueType.swift
//  Cub
//
//  Created by Louis D'hauwe on 19/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public enum ValueType: Equatable {

	case number(NumberType)
	case `struct`([Int: ValueType])
	case bool(Bool)
	case string(String)
	case array([ValueType])

}

public extension ValueType {

	func description(with ctx: BytecodeCompiler) -> String {

		switch self {
		case let .number(val):

			return "\(val)"

		case let .struct(val):

			var descr = "{ "

			for (k, v) in val {

				if let memberName = ctx.getStructMemberName(for: k) {
					descr += "\(memberName) = "
				} else {
					descr += "\(k) = "
				}

				descr += "\(v.description(with: ctx)); "

			}

			descr += " }"

			return descr

		case let .bool(val):
			if val == true {
				return "true"
			} else {
				return "false"
			}
		
		case let .string(val):
			return val
			
		case let .array(val):
			
			var descr = "["

			descr += val.map({ $0.description(with: ctx) }).joined(separator: ", ")
			
			descr += "]"
			
			return descr
		}

	}

}

public func ==(lhs: ValueType, rhs: ValueType) -> Bool {

	if case let ValueType.number(l) = lhs, case let ValueType.number(r) = rhs {
		return l == r
	}

	if case let ValueType.struct(l) = lhs, case let ValueType.struct(r) = rhs {
		return l == r
	}

	if case let ValueType.bool(l) = lhs, case let ValueType.bool(r) = rhs {
		return l == r
	}
	
	if case let ValueType.string(l) = lhs, case let ValueType.string(r) = rhs {
		return l == r
	}
	
	if case let ValueType.array(l) = lhs, case let ValueType.array(r) = rhs {
		return l == r
	}

	return false
}
