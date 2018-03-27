//
//  TerminalTabViewController.swift
//  OpenTerm
//
//  Created by Ian McDowell on 2/3/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import TabView

class TerminalTabViewController: TabViewController {

	required init(theme: TabViewTheme) {
		super.init(theme: theme)

		self.viewControllers = [
			TerminalViewController()
		]

		self.navigationItem.leftBarButtonItems = [
			UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(showSettings))
		]
		self.navigationItem.rightBarButtonItems = [
			UIBarButtonItem(image: #imageLiteral(resourceName: "Add"), style: .plain, target: self, action: #selector(addTab))
		]
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	@objc private func showSettings() {
		let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController")
		let nav = UINavigationController(rootViewController: settingsVC)
		nav.navigationBar.barStyle = .black
		nav.modalPresentationStyle = .formSheet
		self.present(nav, animated: true, completion: nil)
	}

	@objc private func addTab() {
		self.activateTab(TerminalViewController())
	}

	@objc private func closeCurrentTab() {
		if let visibleViewController = self.visibleViewController {
			self.closeTab(visibleViewController)
		}
	}

	override var keyCommands: [UIKeyCommand]? {
		return [
			UIKeyCommand(input: "T", modifierFlags: .command, action: #selector(addTab), discoverabilityTitle: "New tab"),
			UIKeyCommand(input: "W", modifierFlags: .command, action: #selector(closeCurrentTab), discoverabilityTitle: "Close tab")
		]
	}

}
