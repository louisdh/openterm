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

extension ValueType {
	
	var isNumber: Bool {
		if case .number = self {
			return true
		} else {
			return false
		}
	}
	
	var isString: Bool {
		if case .string = self {
			return true
		} else {
			return false
		}
	}
	
	var isBool: Bool {
		if case .bool = self {
			return true
		} else {
			return false
		}
	}
	
	var isArray: Bool {
		if case .array = self {
			return true
		} else {
			return false
		}
	}
	
	var isStruct: Bool {
		if case .struct = self {
			return true
		} else {
			return false
		}
	}
	
}
