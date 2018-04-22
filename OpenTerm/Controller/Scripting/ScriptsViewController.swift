//
//  ScriptsViewController.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/29/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import PanelKit
import TabView

struct PridelandOverview: Equatable {
	
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

class ScriptsViewController: UIViewController {

	var panelManager: TerminalViewController!
	
	enum CellType: Equatable {
		case prideland(PridelandOverview)
		case addNew
	}
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	var cellItems: [CellType]?
	
	var directoryObserver: DirectoryObserver?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Scripts"
		
		collectionView.register(UINib(nibName: "PridelandCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PridelandCollectionViewCell")
		collectionView.register(UINib(nibName: "NewPridelandCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewPridelandCollectionViewCell")
		
		collectionView.dataSource = self
		collectionView.delegate = self

		collectionView.delaysContentTouches = false
		
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
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		self.collectionView.collectionViewLayout.invalidateLayout()

	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		self.collectionView.collectionViewLayout.invalidateLayout()
		
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	@objc
	fileprivate func toggleFullscreen() {

		guard let panelVC = self.panelNavigationController?.panelViewController else {
			return
		}
		
		if panelVC.isFloating || panelVC.isPinned {
			
			floatingModeToFullscreen()
			
		} else {
			
			fullscreenToFloatingMode()
			
		}
		
	}

	func floatingModeToFullscreen() {

		guard let panelVC = self.panelNavigationController?.panelViewController else {
			return
		}
	
		guard let panelManager = self.panelManager else {
			return
		}
		
		guard let terminalTabVC = panelManager.parent?.parent as? TabViewContainerViewController<TerminalTabViewController> else {
			return
		}
		
		panelVC.view.isUserInteractionEnabled = false
		
		let rectInManager = panelVC.view.frame

		let rectInTabVC = terminalTabVC.view.convert(rectInManager, from: panelManager.contentWrapperView)

		panelManager.close(panelVC)
		
		terminalTabVC.view.addSubview(panelVC.view)
		panelVC.view.translatesAutoresizingMaskIntoConstraints = false

		let heightConstraint = panelVC.view.heightAnchor.constraint(equalToConstant: rectInTabVC.height)
		heightConstraint.isActive = true
		
		let widthConstraint = panelVC.view.widthAnchor.constraint(equalToConstant: rectInTabVC.width)
		widthConstraint.isActive = true
		
		let leadingConstraint = panelVC.view.leadingAnchor.constraint(equalTo: terminalTabVC.view.leadingAnchor, constant: rectInTabVC.origin.x)
		leadingConstraint.isActive = true
		
		let topConstraint = panelVC.view.topAnchor.constraint(equalTo: terminalTabVC.view.topAnchor, constant: rectInTabVC.origin.y)
		topConstraint.isActive = true
		
		terminalTabVC.view.layoutIfNeeded()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {

			heightConstraint.isActive = false
			widthConstraint.isActive = false
			leadingConstraint.isActive = false
			topConstraint.isActive = false


			let width1Constraint = panelVC.view.widthAnchor.constraint(equalTo: terminalTabVC.view.widthAnchor)
			width1Constraint.isActive = true

			let height1Constraint = panelVC.view.heightAnchor.constraint(equalTo: terminalTabVC.view.heightAnchor)
			height1Constraint.isActive = true

			panelVC.view.leadingAnchor.constraint(equalTo: terminalTabVC.view.leadingAnchor, constant: 0).isActive = true
			panelVC.view.topAnchor.constraint(equalTo: terminalTabVC.view.topAnchor, constant: 0).isActive = true

			UIView.animate(withDuration: 0.35, animations: {

				terminalTabVC.view.layoutIfNeeded()

			}, completion: { (completed) in

				panelManager.present(panelVC, animated: false, completion: {

					width1Constraint.isActive = false
					height1Constraint.isActive = false

					self.updateNavigationButtons()

					panelVC.view.isUserInteractionEnabled = true

				})

			})

		})

	}
	
	func fullscreenToFloatingMode() {
		
		guard let terminalTabVC = self.presentingViewController as? TabViewContainerViewController<TerminalTabViewController> else {
			return
		}
		
		let primaryTabViewController = terminalTabVC.primaryTabViewController
		
		guard let panelManager = primaryTabViewController.visibleViewController as? TerminalViewController else {
			return
		}
		
		guard let panelVC = self.panelNavigationController?.panelViewController else {
			return
		}
		
		panelVC.view.isUserInteractionEnabled = false
		
		panelVC.dismiss(animated: false) {
			
			terminalTabVC.view.addSubview(panelVC.view)
			
			let heightConstraint = panelVC.view.heightAnchor.constraint(equalTo: terminalTabVC.view.heightAnchor)
			heightConstraint.isActive = true
			
			let widthConstraint = panelVC.view.widthAnchor.constraint(equalTo: terminalTabVC.view.widthAnchor)
			widthConstraint.isActive = true
			
			terminalTabVC.view.layoutIfNeeded()
			
			let rectInManager = CGRect(x: 100, y: 100, width: 400, height: 480)
			
			let rectInTabVC = terminalTabVC.view.convert(rectInManager, from: panelManager.contentWrapperView)
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
				
				heightConstraint.isActive = false
				widthConstraint.isActive = false
				
				let width1Constraint = panelVC.view.widthAnchor.constraint(equalToConstant: rectInTabVC.width)
				width1Constraint.isActive = true
				
				let height1Constraint = panelVC.view.heightAnchor.constraint(equalToConstant: rectInTabVC.height)
				height1Constraint.isActive = true
				
				panelVC.view.leadingAnchor.constraint(equalTo: terminalTabVC.view.leadingAnchor, constant: rectInTabVC.origin.x).isActive = true
				panelVC.view.topAnchor.constraint(equalTo: terminalTabVC.view.topAnchor, constant: rectInTabVC.origin.y).isActive = true
				
				UIView.animate(withDuration: 0.35, animations: {
					
					terminalTabVC.view.layoutIfNeeded()
					
				}, completion: { (completed) in
					
					panelVC.view.removeFromSuperview()
					width1Constraint.isActive = false
					height1Constraint.isActive = false
					panelManager.float(panelVC, at: rectInManager)
					
					self.updateNavigationButtons()

					panelVC.view.isUserInteractionEnabled = true

				})
				
			})
			
		}
		
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
			
			if !fileManager.fileExists(atPath: DocumentManager.shared.scriptsURL.path) {
				try fileManager.createDirectory(at: DocumentManager.shared.scriptsURL, withIntermediateDirectories: true, attributes: nil)
			}

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
		
		var newItems: [CellType] = overviews.map({ .prideland($0) })
		newItems.append(.addNew)
		
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
			case (.addNew, .addNew):
				return true
			default:
				return false
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
		
		guard let cellItem = cellItems?[indexPath.row] else {
			fatalError("Expected cellItem")
		}
		
		switch cellItem {
		case .prideland(let pridelandOverview):
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PridelandCollectionViewCell", for: indexPath) as! PridelandCollectionViewCell

			cell.show(pridelandOverview)
			return cell

		case .addNew:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewPridelandCollectionViewCell", for: indexPath) as! NewPridelandCollectionViewCell
			
			return cell
			
		}
		
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
		
		case .addNew:
			addScript()
			
		}

	}
	
	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		
		guard let cell = collectionView.cellForItem(at: indexPath) else {
			return
		}
		
		UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [.allowUserInteraction], animations: {
			
			cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

		}, completion: nil)
		
	}
	
	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
	
		guard let cell = collectionView.cellForItem(at: indexPath) else {
			return
		}
		
		UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [.allowUserInteraction], animations: {
			
			cell.transform = .identity
			
		}, completion: nil)

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
		
		let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScript))
		
		guard self.panelManager.allowFloatingPanels else {
			return [addBarButtonItem]
		}
		
		let fullscreenImage: UIImage
		
		if self.panelNavigationController?.panelViewController?.isFloating == true {
			
			fullscreenImage = #imageLiteral(resourceName: "Fullscreen")

		} else {

			fullscreenImage = #imageLiteral(resourceName: "CloseFullscreen")
			
		}
		
		let fullscreenBarButtonItem = UIBarButtonItem(image: fullscreenImage, style: .done, target: self, action: #selector(toggleFullscreen))
		
		return [fullscreenBarButtonItem, addBarButtonItem]
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
		
		if self.panelNavigationController?.panelViewController?.isPinned == true {
			return true
		}
		
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
