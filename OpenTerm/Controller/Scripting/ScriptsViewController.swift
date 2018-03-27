//
//  ScriptsViewController.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/29/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import PanelKit

class ScriptsViewController: UITableViewController {

	var scriptNames: [String] = [] {
		didSet {
			tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.tintColor = .defaultMainTintColor
		self.navigationController?.navigationBar.barStyle = .blackTranslucent

		// Remove separators beyond content
		self.tableView.tableFooterView = UIView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		reload()
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	@objc
	fileprivate func addScript() {
		let alertController = UIAlertController(title: "New Script", message: "Enter a unique name for your new script.", preferredStyle: .alert)
		alertController.addTextField { textField in
			textField.placeholder = "script_name"
			textField.autocapitalizationType = .none
			textField.autocorrectionType = .no
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Create", style: .default, handler: { [unowned self] _ in
			guard let name = alertController.textFields?.first?.text else {
				return
			}
			
			Script.create(name)
			self.reload()
		}))
		self.present(alertController, animated: true, completion: nil)
	}

	private func reload() {
		self.scriptNames = Script.allNames
	}
	
}

extension ScriptsViewController {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return scriptNames.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ScriptCell", for: indexPath)

		cell.textLabel?.text = scriptNames[indexPath.row]

		return cell
	}
	
}

extension ScriptsViewController {

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard let script = try? Script.named(scriptNames[indexPath.row]) else {
			return
		}
		let vc = ScriptEditViewController(script: script)
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
}

extension ScriptsViewController: PanelContentDelegate {

	var rightBarButtonItems: [UIBarButtonItem] {
		return [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScript))]
	}

	var preferredPanelContentSize: CGSize {
		return CGSize(width: 320, height: 480)
	}

	var minimumPanelContentSize: CGSize {
		return CGSize(width: 320, height: 320)
	}

	var maximumPanelContentSize: CGSize {
		return CGSize(width: 600, height: 800)
	}

}

extension ScriptsViewController: PanelStateCoder {

	var panelId: Int {
		return 2
	}

}
