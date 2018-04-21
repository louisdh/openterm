//
//  DocumentationItem.swift
//  Cub
//
//  Created by Louis D'hauwe on 20/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct DocumentationItem: Equatable, Codable {
	
	public let definition: String
	public let rawDocumentation: String?
	public let type: DocumentationItemType
	
	// TODO: add these as associated values to `type`.
	public let functionDocumentation: FunctionDocumentation?
	public let variableDocumentation: VariableDocumentation?
	public let structDocumentation: StructDocumentation?
	
	public let title: String

}
