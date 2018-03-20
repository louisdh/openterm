//
//  Bundle+Info.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 20/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

extension Bundle {
	
	public var version: String {
		return object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}
	
	public var build: String {
		return object(forInfoDictionaryKey: "CFBundleVersion") as! String
	}
	
}
