//
//  DocumentationItemType.swift
//  Cub macOS Tests
//
//  Created by Louis D'hauwe on 20/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

enum DocumentationItemTypeDecodingError: Error {
	case invalidValue
}

public enum DocumentationItemType: Equatable, Codable {
	case function(FunctionDocumentation)
	case variable(VariableDocumentation)
	case `struct`(StructDocumentation)
	
	enum CodingKeys: String, CodingKey {
		case function, variable, `struct`
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		if let functionDoc = try container.decodeIfPresent(FunctionDocumentation.self, forKey: .function) {
			self = .function(functionDoc)
		} else if let variableDoc = try container.decodeIfPresent(VariableDocumentation.self, forKey: .variable) {
			self = .variable(variableDoc)
		} else if let structDoc = try container.decodeIfPresent(StructDocumentation.self, forKey: .struct) {
			self = .struct(structDoc)
		} else {
			throw DocumentationItemTypeDecodingError.invalidValue
		}
		
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .function(let functionDoc):
			try container.encode(functionDoc, forKey: .function)
		case .variable(let variableDoc):
			try container.encode(variableDoc, forKey: .variable)
		case .struct(let structDoc):
			try container.encode(structDoc, forKey: .struct)
		}
	}
	
}
