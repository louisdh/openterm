//
//  RunnerError.swift
//  Cub
//
//  Created by Louis D'hauwe on 26/03/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public enum RunnerError: Error {
	case registerNotFound
	case stdlibFailed
	case runFailed
}
