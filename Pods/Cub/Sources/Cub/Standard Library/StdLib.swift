//
//  StdLib.swift
//  Cub
//
//  Created by Louis D'hauwe on 11/12/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public class StdLib {

	private let sources = ["Arithmetic", "Graphics"]

	public init() {

	}

	public func stdLibCode() throws -> String {

		var stdLib = ""

		#if SWIFT_PACKAGE
			
			// Swift packages don't currently have a resources folder
			
			var url = URL(fileURLWithPath: #file)
			url.deleteLastPathComponent()
			url.appendPathComponent("Sources")
			
			let resourcesPath = url.path
			
		#else
			
			let bundle = Bundle(for: type(of: self))

			guard let resourcesPath = bundle.resourcePath else {
				throw StdLibError.resourceNotFound
			}
			
		#endif
		
		for sourceName in sources {

			let resourcePath = "\(resourcesPath)/\(sourceName).cub"

			let source = try String(contentsOfFile: resourcePath, encoding: .utf8)
			stdLib += source

		}
		
		return stdLib
	}

	enum StdLibError: Error {
		case resourceNotFound
	}

}
