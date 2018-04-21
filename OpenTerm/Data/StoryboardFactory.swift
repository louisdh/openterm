//
//  StoryboardFactory.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 04/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import UIKit
import Cub

protocol StoryboardIdentifiable {
	static var storyboardIdentifier: String { get }
}

extension UIStoryboard {
	
	static var main: MainStoryboard {
		return MainStoryboard()
	}
	
}

class MainStoryboard: StoryboardWrapper {
	
	let uiStoryboard: UIStoryboard
	
	init() {
		uiStoryboard = UIStoryboard(name: "Main", bundle: nil)
	}
	
	func scriptMetadataViewController(state: ScriptMetadataState) -> ScriptMetadataViewController {
		let vc: ScriptMetadataViewController = instantiateViewController()
		vc.state = state
		return vc
	}
	
	func manualWebViewController(htmlURL: URL) -> ManualWebViewController {
		let vc: ManualWebViewController = instantiateViewController()
		vc.htmlURL = htmlURL
		return vc
	}
	
	func cubDocumentationViewController() -> CubDocumentationViewController {
		let vc: CubDocumentationViewController = instantiateViewController()
		return vc
	}
	
	func cubDocumentationItemViewController(item: DocumentationItem) -> CubDocumentationItemViewController {
		let vc: CubDocumentationItemViewController = instantiateViewController()
		vc.item = item
		return vc
	}
	
}

protocol StoryboardWrapper {
	
	var uiStoryboard: UIStoryboard { get }
	
}

extension StoryboardWrapper {
	
	// MARK: - Generic
	
	// Alternatively, you could use this generic function,
	// Please note: this requires defining the UIViewController type
	// E.g.:
	// let fooVC: FooViewController = UIStoryboard.main.instantiateViewController()
	//
	// With the convenience functions, you can write:
	// let fooVC = UIStoryboard.main.fooViewController()
	
	func instantiateViewController<T: UIViewController>() -> T where T: StoryboardIdentifiable {
		
		guard let vc: T = instantiateViewController(withIdentifier: T.storyboardIdentifier) else {
			fatalError("Could not instantiate view controller \"\(T.self)\" for identifier: \"\(T.storyboardIdentifier)\"")
		}
		
		return vc
	}
	
	private func instantiateViewController<T: UIViewController>(withIdentifier identifier: String) -> T? {
		return uiStoryboard.instantiateViewController(withIdentifier: identifier) as? T
	}
	
}
