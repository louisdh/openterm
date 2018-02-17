//
//  BytecodeDescriptor.swift
//  Cub
//
//  Created by Louis D'hauwe on 16/06/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public class BytecodeDescriptor {
	
	let bytecode: BytecodeBody
	
	init(bytecode: BytecodeBody) {
		self.bytecode = bytecode
	}
	
	func humanReadableDescription() -> String {
		
		var indentLevel = 0
		
		var totalDescription = ""
		
		var i = 0
		
		for b in bytecode {
			
			i += 1
			
			if b.type == .virtualEnd || b.type == .privateVirtualEnd {
				indentLevel -= 1
			}
			
			var description = ""
			
			if !totalDescription.isEmpty {
				if b.type == .virtualHeader || b.type == .privateVirtualHeader {
					description += "\n"
				}
			}
			
			
			for _ in 0..<indentLevel {
				description += "\t"
			}
			
			description += b.description
			
			if b.type == .virtualEnd || b.type == .privateVirtualEnd {
				description += "\n"
			}
			
			if b.type == .virtualHeader || b.type == .privateVirtualHeader {
				indentLevel += 1
			}
			
			totalDescription += description
			
			if i != bytecode.count {
				totalDescription += "\n"
			}
			
		}
		
		return totalDescription
	}
	
}
