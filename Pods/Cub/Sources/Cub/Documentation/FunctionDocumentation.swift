//
//  FunctionDocumentation.swift
//  Cub
//
//  Created by Louis D'hauwe on 20/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct FunctionDocumentation: Equatable, Codable {
	
	let description: String?
	let argumentDescriptions: [String: String?]
	let returnDescription: String?
	
}
