//
//  RunnerDelegate.swift
//  Cub
//
//  Created by Louis D'hauwe on 26/03/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public protocol RunnerDelegate {

	func log(_ message: String)

	func log(_ error: Error)

	func log(_ token: Token)

}
