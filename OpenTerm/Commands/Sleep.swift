//
//  Sleep.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 23/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import ios_system

@_cdecl("sleepCMD")
public func sleepCMD(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
	
	guard let args = convertCArguments(argc: argc, argv: argv) else {
		return 1
	}
	
	let usage = "Usage: sleep seconds\n"

	guard let secondsString = args[safe: 1], let seconds = UInt32(secondsString) else {
		fputs(usage, thread_stderr)
		return 1
	}
	
	sleep(seconds)

	return 0
}
