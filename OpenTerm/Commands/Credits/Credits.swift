//
//  Credits.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 31/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import ios_system
import TabView

public func credits(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
	
	let logoFileName: String

	// FIXME: commands are currently never run on the main thread,
	// which makes it unsafe to access any UI.
//	if Thread.isMainThread {
	
		guard let tabViewContainer = UIApplication.shared.keyWindow?.rootViewController as? TabViewContainerViewController<TerminalTabViewController> else {
			return 1
		}
		
		guard let activeVC = tabViewContainer.primaryTabViewController.visibleViewController as? TerminalViewController else {
			return 1
		}
		
		let terminalView = activeVC.terminalView
		
		let bigLogoWidth = 48

		if terminalView.columnWidth < bigLogoWidth {
			
			logoFileName = "Logo-small"
			
		} else {
			
			logoFileName = "Logo"
			
		}
		
//	} else {
//
//		logoFileName = "Logo"
//
//	}
	
	var output = "\n"
	
	guard let logoPath = Bundle.main.path(forResource: logoFileName, ofType: "txt") else {
		fputs("Could not get logo path", thread_stderr)
		return 1
	}
	
	guard let logo = try? String(contentsOfFile: logoPath) else {
		fputs("Could not get logo", thread_stderr)
		return 1
	}
	
	output += logo
		
	let version = Bundle.main.version
	let build = Bundle.main.build

	output += "\nv\(version), build \(build)\n"
	
	let decoder = JSONDecoder()
	
	guard let url = Bundle.main.url(forResource: "authors", withExtension: "json") else {
		fputs("Could not get authors", thread_stderr)
		return 1
	}

	guard let authors = try? decoder.decode([Author].self, from: Data(contentsOf: url)) else {
		fputs("Could not parse authors", thread_stderr)
		return 1
	}
	
	let authorsString = "Created by:\n" + authors.map({ $0.name }).joined(separator: "\n")
	
	output += "\n\(authorsString)\n\n"

	fputs(output, thread_stdout)

	return 0
}
