//
//  Dispatch+Custom.swift
//  OpenTerm
//
//  Created by Ian McDowell on 2/10/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

extension DispatchQueue {

	/// Performs the given block on the main thread, without dispatching if already there.
	static func performOnMain(_ block: @escaping () -> Void) {
		if Thread.isMainThread {
			block()
		} else {
			DispatchQueue.main.async(execute: block)
		}
	}
}
