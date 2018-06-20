//
//  BookmarkViewController.swift
//  OpenTerm
//
//  Created by Max Katzmann on 01/02/2018.
//

import UIKit
import PanelKit

/// Protocol that is used to interact with the bookmark view controller.
protocol BookmarkViewControllerDelegate: class {

	/// Notifies the delegate that a bookmark was selected, or retrieves the current directory.
	///
	/// - Parameter bookmarkURL: The bookmark that was selected.
	var currentDirectoryURL: URL { get set }
}

class BookmarkViewController: UIViewController {

	//  Stores all bookmarked URLs.
	var bookmarks = [URL]()

	let bookmarkManager = BookmarkManager()

	weak var delegate: BookmarkViewControllerDelegate?

	@IBOutlet weak var tableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()

		self.bookmarkManager.delegate = self

		self.title = "Bookmarks"
		self.view.tintColor = .defaultMainTintColor
		self.navigationController?.navigationBar.barStyle = .blackTranslucent

		// Remove separators beyond content
		self.tableView.tableFooterView = UIView()

		//  Get all the saved bookmarks from the delegate.
		self.bookmarks = self.bookmarkManager.savedBookmarkURLs()

		tableView.dataSource = self
		tableView.delegate = self
	}

	/// When the + button is pressed, we notify the delegate to save the current
	/// directory as URL.
	@objc func addBookmarkForCurrentDirectory() {
		guard let url = self.delegate?.currentDirectoryURL else {
			return
		}
		
		do {
			try self.bookmarkManager.saveBookmarkURL(url: url)
		} catch {
			//  We inform the user that the bookmark could not be saved.
			let alertController = UIAlertController(title: "Could not save bookmark.",
													message: error.localizedDescription,
													preferredStyle: .alert)

			let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)

			alertController.addAction(cancelAction)

			self.present(alertController, animated: true, completion: nil)
		}
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

}

extension BookmarkViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return bookmarks.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")

		cell.backgroundColor = self.view.backgroundColor

		//  Show the name of the bookmark (last path component) and the actual file path in the cell.
		let bookmarkURL = bookmarks[indexPath.row]

		let urlDescription = NSMutableString(string: bookmarkURL.absoluteURL.path)
		OutputSanitizer.sanitize(urlDescription)

		cell.textLabel?.text = "\(bookmarkURL.lastPathComponent): \(urlDescription)"

		cell.textLabel?.textColor = .white
		cell.textLabel?.font = UIFont(name: "Menlo", size: 16)

		return cell
	}

	//  Enable deleting a bookmark by swiping the corresponding cell.
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

		//  If the bookmark should be deleted...
		if editingStyle == .delete {

			//  Notify the delegate that this bookmark should be deleted.
			let bookmarkURLToDelete = self.bookmarks[indexPath.row]
			self.bookmarkManager.deleteBookmarkURL(bookmarkURL: bookmarkURLToDelete)

			//  Then delete the row from the table view.
			self.bookmarks.remove(at: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}

}

extension BookmarkViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		//  When a bookmark is selected, we notify the delegate about this.
		let selectedBookmarkURL = bookmarks[indexPath.row]
		delegate?.currentDirectoryURL = selectedBookmarkURL

		if let panelVC = self.panelNavigationController?.panelViewController {
			if panelVC.isFloating == false {
				self.dismiss(animated: true, completion: nil)
			}
		}
	}

}

extension BookmarkViewController: PanelContentDelegate {

	var preferredPanelContentSize: CGSize {
		return CGSize(width: 320, height: 480)
	}

	var minimumPanelContentSize: CGSize {
		return CGSize(width: 320, height: 320)
	}

	var maximumPanelContentSize: CGSize {
		return CGSize(width: 1000, height: 800)
	}

	/**
	*  Put a + button on the right side of the navigation bar that is used
	*  to add a new bookmark.
	*/
	var rightBarButtonItems: [UIBarButtonItem] {
		let addButton = UIBarButtonItem(barButtonSystemItem: .add,
										target: self,
										action: #selector(addBookmarkForCurrentDirectory))
		return [addButton]
	}
}

extension BookmarkViewController: PanelStateCoder {

	var panelId: Int {
		return 3
	}

}

extension BookmarkViewController: BookmarkManagerDelegate {

	/// When the delegate notifies us that the saved bookmarks were changed
	/// we reload the table view.
	func bookmarksWereUpdated() {

		let updatedBookmarks = self.bookmarkManager.savedBookmarkURLs()
		self.bookmarks = updatedBookmarks
		self.tableView.reloadSections(IndexSet(integer: 0),
									  with: .automatic)

	}

}
