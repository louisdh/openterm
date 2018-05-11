//
//  StructDocumentation.swift
//  Cub
//
//  Created by Louis D'hauwe on 21/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct StructDocumentation: Equatable, Codable {
	
	public let name: String
	public let description: String?
	public let members: [String]
	public let memberDescriptions: [String: String]
	
}
