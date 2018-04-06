//
//  Savanna.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 07/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import Cub
import ios_system
import TabView
import PanelKit

public func savanna(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
	
	guard let tabViewContainer = UIApplication.shared.keyWindow?.rootViewController as? TabViewContainerViewController<TerminalTabViewController> else {
		return 1
	}
	
	guard let activeVC = tabViewContainer.primaryTabViewController.visibleViewController as? TerminalViewController else {
		return 1
	}
	
	let usage = "Usage: savanna script.cub\n"
	
	guard argc == 2 else {
		fputs(usage, thread_stderr)
		return 1
	}
	
	guard let fileName = argv?[1] else {
		fputs(usage, thread_stderr)
		return 1
	}
	
	let path = String(cString: fileName)
	
	let url = URL(fileURLWithPath: path)
	
	DispatchQueue.main.async {
		
		let scriptVC = ScriptEditViewController(url: url)
		
		let panelVC = PanelViewController(with: scriptVC, in: activeVC)
		activeVC.cubPanels.append(panelVC)
		
		activeVC.float(panelVC, at: CGRect(x: 100, y: 100, width: 320, height: 480))

	}

	return 0
}
