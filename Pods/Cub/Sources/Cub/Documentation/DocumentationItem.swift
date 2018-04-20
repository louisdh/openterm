//
//  DocumentationItem.swift
//  Cub
//
//  Created by Louis D'hauwe on 20/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct DocumentationItem: Equatable, Codable {
	
	let definition: String
	let rawDocumentation: String?
	let type: DocumentationItemType
	let functionDocumentation: FunctionDocumentation?
	
}
