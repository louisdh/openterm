//
//  ScriptsViewController.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/29/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import PanelKit

class ScriptsViewController: UIViewController {

	@IBOutlet weak var collectionView: UICollectionView!
	
	var scriptNames: [String] = [] {
		didSet {
			collectionView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Scripts"
		
		collectionView.register(UINib(nibName: "PridelandCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PridelandCollectionViewCell")

		collectionView.dataSource = self
		collectionView.delegate = self

		self.view.tintColor = .defaultMainTintColor
		self.navigationController?.navigationBar.barStyle = .blackTranslucent

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

extension ScriptsViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return scriptNames.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PridelandCollectionViewCell", for: indexPath) as! PridelandCollectionViewCell
		
		let prideland = scriptNames[indexPath.row]
		
		cell.show(prideland)
		
		return cell
	}
	
}

extension ScriptsViewController: UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let preferedWidth: CGFloat = 240
		
		let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - 32
		
		let columns = max(1, Int(availableWidth / preferedWidth))
		
		let spacing: CGFloat = 16
		
		let width: CGFloat = (availableWidth - ((CGFloat(columns) - 1.0) * spacing)) / CGFloat(columns)
		
		return CGSize(width: width, height: 88)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let prideland = scriptNames[indexPath.row]

		guard let script = try? Script.named(prideland) else {
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
	
	var shouldAdjustForKeyboard: Bool {
		
		if let scriptVC = self.navigationController?.visibleViewController as? ScriptEditViewController {
			return scriptVC.shouldAdjustForKeyboard
		}
		
		return false
	}

}

extension ScriptsViewController: PanelStateCoder {

	var panelId: Int {
		return 2
	}

}
