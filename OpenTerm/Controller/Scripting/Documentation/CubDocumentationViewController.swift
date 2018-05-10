//
//  CubDocumentationViewController.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 21/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import PanelKit
import Cub

class CubDocumentationViewController: UIViewController {

	enum Section {
		case functions([DocumentationItem])
		case variables([DocumentationItem])
		case structs([DocumentationItem])
	}
	
	enum CellType {
		case docItem(DocumentationItem)
	}
	
	lazy var docBundle: CubDocumentationBundle = {
		
		guard let docBundleURL = Bundle.main.url(forResource: "cub-docs", withExtension: "json", subdirectory: nil) else {
			fatalError("Couldn't get docBundleURL")
		}

		guard let data = FileManager.default.contents(atPath: docBundleURL.path) else {
			fatalError("Couldn't get data")
		}
		
		let decoder = JSONDecoder()

		guard let bundle = try? decoder.decode(CubDocumentationBundle.self, from: data) else {
			fatalError("Couldn't get bundle")
		}

		return bundle
	}()
	
	lazy var allItems: [DocumentationItem] = {
		return docBundle.items
	}()
	
	var sections: [Section]?
	
	func updateSections(searchText: String? = nil) {
		
		var sections = [Section]()
		
		var sortedItems = allItems.sorted(by: { $0.definition < $1.definition })
		
		if let searchText = searchText?.lowercased(), !searchText.isEmpty {
			sortedItems = sortedItems.filter({ $0.title.lowercased().contains(searchText) })
		}
		
		let functionItemsToShow = sortedItems.filter({
			if case .function = $0.type {
				return true
			}
			return false
		})
		
		if !functionItemsToShow.isEmpty {
			sections.append(.functions(functionItemsToShow))
		}
		
		let variableItemsToShow = sortedItems.filter({
			if case .variable = $0.type {
				return true
			}
			return false
		})
		
		if !variableItemsToShow.isEmpty {
			sections.append(.variables(variableItemsToShow))
		}
		
		let structItemsToShow = sortedItems.filter({
			if case .struct = $0.type {
				return true
			}
			return false
		})
		
		if !structItemsToShow.isEmpty {
			sections.append(.structs(structItemsToShow))
		}
		
		self.sections = sections
		
		self.tableView.reloadData()
	}
	
	@IBOutlet weak var tableView: UITableView!
	
	let searchController = UISearchController(searchResultsController: nil)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let cellNib = UINib(nibName: "CubDocumentationItemTableViewCell", bundle: .main)
		tableView.register(cellNib, forCellReuseIdentifier: "CubDocumentationItemTableViewCell")

		tableView.delegate = self
		tableView.dataSource = self
		
		self.navigationController?.navigationBar.barStyle = .blackTranslucent
		self.navigationItem.backBarButtonItem?.title = ""

		updateSections()
		
		searchController.searchBar.barStyle = .blackTranslucent
		searchController.dimsBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = false
		searchController.searchBar.keyboardAppearance = .dark
		
		searchController.searchResultsUpdater = self
		navigationItem.searchController = searchController

    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
}

extension CubDocumentationViewController: UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		
		updateSections(searchText: searchController.searchBar.text)
		
	}
	
}

extension CubDocumentationViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		guard let section = sections?[indexPath.section] else {
			return
		}
		
		let item: DocumentationItem
		
		switch section {
		case .functions(let items):
			item = items[indexPath.row]
			
		case .variables(let items):
			item = items[indexPath.row]
			
		case .structs(let items):
			item = items[indexPath.row]

		}
		
		let itemVC = UIStoryboard.main.cubDocumentationItemViewController(item: item)
		
		self.navigationController?.pushViewController(itemVC, animated: true)
		
	}
	
}

extension CubDocumentationViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		guard let section = sections?[section] else {
			return nil
		}
		
		switch section {
		case .functions:
			return "Functions"
			
		case .variables:
			return "Variables"
			
		case .structs:
			return "Structs"

		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return sections?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		guard let section = sections?[section] else {
			fatalError("No section found")
		}
		
		switch section {
		case .functions(let items):
			return items.count
			
		case .variables(let items):
			return items.count
			
		case .structs(let items):
			return items.count

		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let section = sections?[indexPath.section] else {
			fatalError("No section found")
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "CubDocumentationItemTableViewCell", for: indexPath) as! CubDocumentationItemTableViewCell
		
		switch section {
		case .functions(let items):
			let item = items[indexPath.row]
			
			cell.titleLbl.text = item.title
			
			return cell
			
		case .variables(let items):
			let item = items[indexPath.row]

			cell.titleLbl.text = item.title

			return cell
			
		case .structs(let items):
			let item = items[indexPath.row]
			
			cell.titleLbl.text = item.title
			
			return cell
		}
		
	}
	
}

extension CubDocumentationViewController: PanelContentDelegate {
	
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
		return searchController.searchBar.isFirstResponder
	}
	
}

extension CubDocumentationViewController: StoryboardIdentifiable {
	
	static var storyboardIdentifier: String {
		return "CubDocumentationViewController"
	}
	
}
