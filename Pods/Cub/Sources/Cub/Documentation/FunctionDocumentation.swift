//
//  FunctionDocumentation.swift
//  Cub
//
//  Created by Louis D'hauwe on 20/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct FunctionDocumentation: Equatable, Codable {
	
	public let description: String?
	public let arguments: [String]
	public let argumentDescriptions: [String: String?]
	public let returnDescription: String?
	
}
