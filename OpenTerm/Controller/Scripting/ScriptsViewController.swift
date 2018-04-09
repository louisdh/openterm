//
//  ScriptsViewController.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/29/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import PanelKit

struct PridelandOverview {
	
	let url: URL
	let metadata: PridelandMetadata

	init(url: URL, fileWrapper: FileWrapper) throws {

		guard let wrappers = fileWrapper.fileWrappers else {
			throw PridelandDocumentError.invalidDocument
		}
	
		guard let metadataData = wrappers["metadata.plist"]?.regularFileContents else {
			throw PridelandDocumentError.invalidDocument
		}
		
		let decoder = PropertyListDecoder()
		
		guard let metadata = try? decoder.decode(PridelandMetadata.self, from: metadataData) else {
			throw PridelandDocumentError.invalidDocument
		}
		
		self.metadata = metadata
		self.url = url
		
	}
	
}

extension PridelandOverview: Equatable {
	
	static func ==(lhs: PridelandOverview, rhs: PridelandOverview) -> Bool {
		return lhs.url == rhs.url &&
			lhs.metadata == rhs.metadata
	}
	
}

class ScriptsViewController: UIViewController {

	enum CellType: Equatable {
		case prideland(PridelandOverview)
		
		static func ==(lhs: CellType, rhs: CellType) -> Bool {
			switch (lhs, rhs) {
			case let (.prideland(overview1), .prideland(overview2)):
				return overview1 == overview2
			}
		}
	}
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	var cellItems: [CellType]?
	
	var directoryObserver: DirectoryObserver?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Scripts"
		
		collectionView.register(UINib(nibName: "PridelandCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PridelandCollectionViewCell")

		collectionView.dataSource = self
		collectionView.delegate = self

		self.view.tintColor = .defaultMainTintColor
		self.navigationController?.navigationBar.barStyle = .blackTranslucent

		directoryObserver = DirectoryObserver(pathToWatch: DocumentManager.shared.scriptsURL) { [weak self] in
			self?.reload()
		}
		
		try? directoryObserver?.startObserving()
		
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		reload()
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		
		coordinator.animate(alongsideTransition: { (ctx) in
			
			
		}, completion: { (ctx) in
			
			self.collectionView.collectionViewLayout.invalidateLayout()

		})
		
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	@objc
	fileprivate func addScript() {
		
		let scriptMetadataVC = UIStoryboard.main.scriptMetadataViewController(state: .create)
		scriptMetadataVC.delegate = self
		
		let navController = UINavigationController(rootViewController: scriptMetadataVC)
		navController.navigationBar.barStyle = .blackTranslucent
		navController.modalPresentationStyle = .formSheet
		
		self.present(navController, animated: true, completion: nil)
		
	}

	private func reload() {
		
		let fileManager = DocumentManager.shared.fileManager
		
		do {

			let documentsURLs = try fileManager.contentsOfDirectory(at: DocumentManager.shared.scriptsURL, includingPropertiesForKeys: [], options: .skipsPackageDescendants)
			
			var pridelandOverviews = [PridelandOverview]()
			
			for documentURL in documentsURLs {

				let pathExtension = documentURL.pathExtension.lowercased()
				
				if pathExtension == "icloud" {
					try fileManager.startDownloadingUbiquitousItem(at: documentURL)
					continue
				}
				
				guard pathExtension == "prideland" else {
					continue
				}
				
				let fileWrapper = try FileWrapper(url: documentURL, options: [])
				
				let overview = try PridelandOverview(url: documentURL, fileWrapper: fileWrapper)
				
				pridelandOverviews.append(overview)
				
			}
			
			pridelandOverviews.sort(by: { $0.metadata.name < $1.metadata.name })
			updatePridelandItems(pridelandOverviews)
			
		} catch {
			
			self.showErrorAlert(error)
			
		}
			
	}
	
	func updatePridelandItems(_ overviews: [PridelandOverview]) {
		
		let newItems: [CellType] = overviews.map({ .prideland($0) })
		
		guard let prevItems = cellItems else {
			cellItems = newItems
			collectionView.reloadData()
			return
		}
		
		collectionView.update(dataSourceUpdateClosure: {
			
			cellItems = newItems
			
		}, section: 0, from: prevItems, to: newItems, sameIdentityClosure: { (p1, p2) -> Bool in
			
			switch (p1, p2) {
			case let (.prideland(overview1), .prideland(overview2)):
				return overview1.url == overview2.url
			}
			
		}, sameValueClosure: { (p1, p2) -> Bool in
			
			return p1 == p2
			
		})
		
	}
	
}

extension ScriptsViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cellItems?.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PridelandCollectionViewCell", for: indexPath) as! PridelandCollectionViewCell
		
		guard let cellItem = cellItems?[indexPath.row] else {
			return cell
		}
		
		switch cellItem {
		case .prideland(let pridelandOverview):
			cell.show(pridelandOverview)
		}
		
		return cell
	}
	
}

extension ScriptsViewController: UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let preferredWidth: CGFloat = 240
		
		let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - 32
		
		let columns = max(1, Int(availableWidth / preferredWidth))
		
		let spacing: CGFloat = 16
		
		let width: CGFloat = (availableWidth - ((CGFloat(columns) - 1.0) * spacing)) / CGFloat(columns)
		
		return CGSize(width: width, height: 100)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let cellItem = cellItems?[indexPath.row] else {
			return
		}
		
		switch cellItem {
		case .prideland(let pridelandOverview):
			openPrideland(url: pridelandOverview.url, title: pridelandOverview.metadata.name)
			
		}

	}
	
	func openPrideland(url: URL, title: String) {
		
		let scriptVC = ScriptEditViewController(url: url)
		scriptVC.title = title
		self.navigationController?.pushViewController(scriptVC, animated: true)
		
	}
	
}

extension ScriptsViewController: ScriptMetadataViewControllerDelegate {
	
	func didUpdateScript(_ updatedDocument: PridelandDocument) {
		self.reload()
	}
	
	func didCreateScript(_ document: PridelandDocument) {
		self.reload()
		openPrideland(url: document.fileURL, title: document.metadata?.name ?? "")
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
