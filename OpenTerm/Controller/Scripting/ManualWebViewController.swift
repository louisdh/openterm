//
//  ManualWebViewController.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 15/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import WebKit
import PanelKit

class ManualWebViewController: UIViewController {
	
	@IBOutlet weak var webView: WKWebView!
	
	var htmlURL: URL!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.tintColor = UIColor(hexString: "#ef5433")
		webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
		
	}
	
}

extension ManualWebViewController: StoryboardIdentifiable {
	
	static var storyboardIdentifier: String {
		return "ManualWebViewController"
	}
	
}

extension ManualWebViewController: PanelContentDelegate {
	
	var preferredPanelContentSize: CGSize {
		return CGSize(width: 420, height: 480)
	}
	
	var minimumPanelContentSize: CGSize {
		return CGSize(width: 320, height: 320)
	}
	
	var maximumPanelContentSize: CGSize {
		return CGSize(width: 600, height: 1400)
	}
	
	var shouldAdjustForKeyboard: Bool {
		return true
	}
	
}
