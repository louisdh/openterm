//
//  Stdin+Read.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 11/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import ios_system

func readStdinBytes() -> [Int8] {
	
	var bytes = [Int8]()
	
	while stdin != thread_stdin {
		var byte: Int8 = 0
		let count = read(fileno(thread_stdin), &byte, 1)
		guard count == 1 else {
			break
		}
		bytes.append(byte)
	}
	
	return bytes
}
