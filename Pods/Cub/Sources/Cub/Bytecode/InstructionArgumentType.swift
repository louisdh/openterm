//
//  InstructionArgumentType.swift
//  Cub
//
//  Created by Louis D'hauwe on 02/02/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public enum InstructionArgumentType {

	case value(ValueType)
	case index(Int)

	var encoded: String {

		switch self {
		case let .value(v):
			return "v\(v)"
		case let .index(i):
			return "i\(i)"
		}

	}

}
