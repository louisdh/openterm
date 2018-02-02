//
//  ViewController.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 07/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import CoreFoundation
import Darwin
import UIKit
import ios_system
import PanelKit
import StoreKit
import MobileCoreServices

extension String {
	func toCString() -> UnsafePointer<Int8>? {
		let nsSelf: NSString = self as NSString
		return nsSelf.cString(using: String.Encoding.utf8.rawValue)
	}
}

extension String {

	var utf8CString: UnsafeMutablePointer<Int8> {
		return UnsafeMutablePointer(mutating: (self as NSString).utf8String!)
	}

}

class ViewController: UIViewController {

	@IBOutlet weak var terminalView: TerminalView!

	@IBOutlet weak var contentWrapperView: UIView!

	var historyViewController: HistoryViewController!
	var historyPanelViewController: PanelViewController!

	var scriptsViewController: ScriptsViewController!
	var scriptsPanelViewController: PanelViewController!
    
    var bookmarkViewController: BookmarkViewController!
    var bookmarkPanelViewController: PanelViewController!

    let executor = CommandExecutor()

	override func viewDidLoad() {
		super.viewDidLoad()

		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		historyViewController = storyboard.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
		historyViewController.delegate = self

		historyPanelViewController = PanelViewController(with: historyViewController, in: self)

		scriptsViewController = storyboard.instantiateViewController(withIdentifier: "ScriptsViewController") as! ScriptsViewController
		scriptsPanelViewController = PanelViewController(with: scriptsViewController, in: self)

        bookmarkViewController = storyboard.instantiateViewController(withIdentifier: "BookmarkViewController") as! BookmarkViewController
        bookmarkViewController.delegate = self
        
        bookmarkPanelViewController = PanelViewController(with: bookmarkViewController, in: self)
        
        executor.delegate = self

		terminalView.delegate = self

		updateTitle()

		NotificationCenter.default.addObserver(self, selector: #selector(didDismissKeyboard), name: .UIKeyboardDidHide, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)

        initializeEnvironment()
        replaceCommand("open-url", openUrl, true)
        replaceCommand("share", shareFile, true)
        replaceCommand("pbcopy", pbcopy, true)
        replaceCommand("pbpaste", pbpaste, true)

        // Call reloadData for the added commands.
        terminalView.autoCompleteManager.reloadData()
        
        shareFileViewController = self // shareFile needs to know which view controller to present share sheet from

		setSSLCertIfNeeded()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.terminalView.becomeFirstResponder()

	}

	var didFirstLayout = false

	override func viewDidLayoutSubviews() {
		 super.viewDidLayoutSubviews()

		if !didFirstLayout {
			restorePanelStatesFromDisk()

			didFirstLayout = true
		}

	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		coordinator.animate(alongsideTransition: { (context) in

		}) { (_) in

			if !self.allowFloatingPanels {
				self.closeAllFloatingPanels()
			}

			if !self.allowPanelPinning {
				self.closeAllPinnedPanels()
			}

		}

	}

	func setSSLCertIfNeeded() {
		
		guard let cString = getenv("SSL_CERT_FILE") else {
			return
		}
			
		guard let str = NSString(cString: cString, encoding: String.Encoding.utf8.rawValue) as String? else {
			return
		}
	
		let fileManager = DocumentManager.shared.fileManager
		
		if !fileManager.fileExists(atPath: str) {
			
			guard let url = Bundle.main.url(forResource: "cacert", withExtension: "pem") else {
				return
			}
			
			guard let data = try? Data(contentsOf: url) else {
				return
			}
			
			let certsFolderURL = DocumentManager.shared.activeDocumentsFolderURL.appendingPathComponent(".certs")
			
			let newURL = certsFolderURL.appendingPathComponent("cacert.pem")
			
			do {
				
				try fileManager.createDirectory(at: certsFolderURL, withIntermediateDirectories: true, attributes: nil)
				
				try data.write(to: newURL)
				setenv("SSL_CERT_FILE", newURL.path.toCString(), 1)

			} catch {
				print(error)
			}

		}
		
	}
	
	var didRequestReview = false

	@objc
	func didDismissKeyboard() {

		guard !didRequestReview else {
			return
		}

		if HistoryManager.history.count > 5 {
			SKStoreReviewController.requestReview()
			didRequestReview = true
		}

	}

	@objc
	func applicationDidEnterBackground() {

		savePanelStates()

	}

	@IBAction func openFolder(_ sender: UIBarButtonItem) {

		terminalView.resignFirstResponder()

		let picker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
		picker.allowsMultipleSelection = true
		picker.delegate = self

		self.present(picker, animated: true, completion: nil)

	}

	@IBAction func showHistory(_ sender: UIBarButtonItem) {

		historyPanelViewController.modalPresentationStyle = .popover
		historyPanelViewController.popoverPresentationController?.barButtonItem = sender

		historyPanelViewController.popoverPresentationController?.backgroundColor = historyViewController.view.backgroundColor
		present(historyPanelViewController, animated: true, completion: nil)

	}

    @IBAction func showHBookmarks(_ sender: UIBarButtonItem) {
        
        bookmarkPanelViewController.modalPresentationStyle = .popover
        bookmarkPanelViewController.popoverPresentationController?.barButtonItem = sender
        
        bookmarkPanelViewController.popoverPresentationController?.backgroundColor = bookmarkViewController.view.backgroundColor
        present(bookmarkPanelViewController, animated: true, completion: nil)
        
    }
    
	@IBAction func showScripts(_ sender: UIBarButtonItem) {

		scriptsPanelViewController.modalPresentationStyle = .popover
		scriptsPanelViewController.popoverPresentationController?.barButtonItem = sender

		scriptsPanelViewController.popoverPresentationController?.backgroundColor = scriptsViewController.view.backgroundColor
		present(scriptsPanelViewController, animated: true, completion: nil)

	}

	func availableCommands() -> [String] {

        let commands = String(commandsAsString())

		guard let data = commands.data(using: .utf8) else {
			assertionFailure("Expected valid data")
			return []
		}

		guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
			assertionFailure("Expected valid json")
			return []
		}

		guard var arr = (json as? [String]) else {
			assertionFailure("Expected String Array")
			return []
		}

		arr.append("clear")
		arr.append("help")

		return arr.sorted()
	}

	func printCommands() {

		print(availableCommands().joined(separator: "\n"))

	}

	func updateTitle() {

		let url = URL(fileURLWithPath: DocumentManager.shared.fileManager.currentDirectoryPath)
		self.title = url.lastPathComponent

	}

	var commandIndex = 0

	@objc func selectPreviousCommand() {

		guard commandIndex < HistoryManager.history.count else {
			return
		}

		commandIndex += 1

		terminalView.currentCommand = HistoryManager.history[commandIndex - 1]

	}

	@objc func selectNextCommand() {

		guard commandIndex > 0 else {
			return
		}

		commandIndex -= 1

		if commandIndex == 0 {
			terminalView.currentCommand = ""
		} else {
			terminalView.currentCommand = HistoryManager.history[commandIndex - 1]
		}

	}

    @objc func clearBufferCommand() {
        terminalView.clearScreen()
        terminalView.writePrompt()
    }

//    @objc func selectCommandHome() {
//        // FIXME: set cursor to start of line and offset with deviceName
//        // Maybe by finding the last "\n"?
//    }

    @objc func selectCommandEnd() {
        let endPosition = terminalView.textView.endOfDocument
        terminalView.textView.selectedTextRange = terminalView.textView.textRange(from: endPosition, to: endPosition)
    }

	override var keyCommands: [UIKeyCommand]? {

		let prevCmd = UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(selectPreviousCommand), discoverabilityTitle: "Previous command")

		let nextCmd = UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(selectNextCommand), discoverabilityTitle: "Next command")

		let clearBufferCmd = UIKeyCommand(input: "K", modifierFlags: .command, action: #selector(clearBufferCommand), discoverabilityTitle: "Clear Buffer")

//		let homeCmd = UIKeyCommand(input: "A", modifierFlags: .control, action: #selector(selectCommandHome), discoverabilityTitle: "Home")

		let endCmd = UIKeyCommand(input: "E", modifierFlags: .control, action: #selector(selectCommandEnd), discoverabilityTitle: "End")

		return [
			prevCmd,
			nextCmd,
			clearBufferCmd,
//			homeCmd,
			endCmd
		]
	}

}

extension ViewController: UIDocumentPickerDelegate {

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

		guard let firstFolder = urls.first else {
			return
		}

		_ = firstFolder.startAccessingSecurityScopedResource()

		DocumentManager.shared.fileManager.changeCurrentDirectoryPath(firstFolder.path)

		self.updateTitle()

	}

}

extension ViewController: BookmarkViewControllerDelegate {
    
    /// The file name of the start directory bookmark. It is stored as a static
    /// constant so we can access it when saving or loading the bookmark and
    /// such that the settings view controller can access is as well.
    static let bookmarkDirectory = ".bookmarks"
    
    
    /// Gets the URLs of the bookmarks that were previously saved.
    ///
    /// - Returns: The URLs of the saved bookmarks. If something fails, the returned array will be empty.
    func savedBookmarkURLs() -> [URL] {
        /**
         *  Get the document directory of the app.
         */
        if let dir = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask).first {
            
            /**
             *  Get the directory where the bookmarks are saved.
             */
            let bookmarkDirectoryURL = dir.appendingPathComponent(ViewController.bookmarkDirectory,
                                                                  isDirectory: true)
            
            /**
             *  Create the bookmarks directory (if it doesn't exist)
             */
            do {
                try FileManager.default.createDirectory(at: bookmarkDirectoryURL,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                
                /**
                 *  Get all files that are in the bookmarks directory.
                 */
                let bookmarkFiles = try FileManager.default.contentsOfDirectory(atPath: bookmarkDirectoryURL.path)
                
                /**
                 *  The array that will hold the obtained URLs. This will be returned eventually.
                 */
                var bookmarkURLs = [URL]()
                
                /**
                 *  Iterate all bookmark filenames.
                 */
                for bookmarkFileName in bookmarkFiles {
                    
                    /**
                     *  Get the url of the current bookmark file.
                     */
                    let bookmarkDataURL = bookmarkDirectoryURL.appendingPathComponent(bookmarkFileName)
                    
                    /**
                     *  We try to load the bookmark from the file.
                     */
                    let loadedBookmark = try URL.bookmarkData(withContentsOf: bookmarkDataURL)
                    
                    /**
                     *  This variable will indicate whether the bookmark is stale.
                     *  If the bookmark is stale we create a new bookmark with the
                     *  obtained URL and save the new one instead of the old one.
                     */
                    var isStale = true
                    
                    /**
                     *  Try to obtain the URL from the bookmark.
                     */
                    if let loadedBookmarkURL = try URL(resolvingBookmarkData: loadedBookmark, bookmarkDataIsStale: &isStale) {
                        
                        /**
                         *  If the bookmark is stale, we create a new bookmark
                         *  from the obtained URL.
                         */
                        if isStale {
                            do {
                                try self.saveBookmarkURL(url: loadedBookmarkURL)
                            }
                        }
                        
                        /**
                         *  Append the loaded URLs.
                         */
                        bookmarkURLs.append(loadedBookmarkURL)
                    }
                }
                
                return bookmarkURLs
            } catch {
                return []
            }
        }
        
        return []
    }
    
    /// When the bookmark view controller did select a bookmark, we change the
    /// current directory to the bookmarked url.
    /// - Note: Only urls that were saved as bookmarks will work.
    ///
    /// - Parameter bookmarkURL: The bookmark that was selected.
    func didSelectBookmarkURL(bookmarkURL: URL) {
        
        /**
         *  Access the bookmarked URL
         */
        _ = bookmarkURL.startAccessingSecurityScopedResource()
        
        /**
         *  Change the directory to the bookmarked path.
         */
        DocumentManager.shared.fileManager.changeCurrentDirectoryPath(bookmarkURL.path)
        
        /**
         *  Update the title.
         */
        self.updateTitle()
    }
    
    /// Determines the current directory and saves the corresponding path as
    /// bookmark.
    ///
    /// - Parameter sender: The view controller that asks to save the current directory. (Might be used to display alerts.)
    func saveBookmarkForCurrentDirectory(sender: UIViewController) {
        /**
         *  Get the path of the current directory and create the corresponding URL.
         */
        let currentDirectoryPath = DocumentManager.shared.fileManager.currentDirectoryPath
        let currentDirectoryURL = URL(fileURLWithPath: currentDirectoryPath)
        
        /**
         *  If saving the URL fails, we show an alert with the error.
         */
        do {
            try self.saveBookmarkURL(url: currentDirectoryURL)
        } catch {
            /**
             *  We inform the user that the bookmark could not be saved.
             */
            let alertController = UIAlertController(title: "Could not save bookmark.",
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: nil)
            
            alertController.addAction(cancelAction)
            
            sender.present(alertController,
                           animated: true,
                           completion: nil)
        }
    }
    
    /// Saves the passed url as a bookmark.
    ///
    /// - Parameter url: The url to be saved as a bookmark.
    func saveBookmarkURL(url: URL) throws {
        /**
         *  Getting the bookmark data for the current URL can fail. E.g.,
         *  when we don't have access to the corresponding security scoped
         *  resource. However, since the user can only save a directory URL
         *  that is currently accessed, this should not happen.
         */
        do {
            /**
             *  Get the bookmark data for the URL making sure it is suitable
             *  to be saved as a file.
             */
            let bookmark = try url.bookmarkData(options: .suitableForBookmarkFile,
                                                includingResourceValuesForKeys: nil,
                                                relativeTo: nil)
            
            /**
             *  Get the document directory of the app. The bookmarks will be saved
             *  in a hidden folder there.
             */
            if let dir = FileManager.default.urls(for: .documentDirectory,
                                                  in: .userDomainMask).first {
                
                /**
                 *  Get the URL of the bookmark directory (where the bookmarks are saved).
                 */
                let bookmarkDirectoryURL = dir.appendingPathComponent(ViewController.bookmarkDirectory,
                                                                      isDirectory: true)
                
                /**
                 *  Create the bookmarks directory (if it doesn't exist)
                 */
                try FileManager.default.createDirectory(at: bookmarkDirectoryURL,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                
                /**
                 *  The URL for where the bookmark data will be saved.
                 */
                let bookmarkDataURL = bookmarkDirectoryURL.appendingPathComponent(url.lastPathComponent,
                                                                                  isDirectory: false)
                
                /**
                 *  Actually saving the bookmark data.
                 */
                try URL.writeBookmarkData(bookmark, to: bookmarkDataURL)
                
                /**
                 *  Tell the bookmark view controller that the bookmarks were updated.
                 */
                self.bookmarkViewController.bookmarksWereUpdated()
            }
        } catch {
            throw error
        }
    }
    
    /// Deletes a URL from the bookmarks.
    ///
    /// - Parameter bookmarkURL: The URL to be deleted.
    func deleteBookmarkURL(bookmarkURL: URL) {
        /**
         *  Get the document directory of the app.
         */
        if let dir = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask).first {
            
            /**
             *  Get the directory of where the bookmarks are saved.
             */
            let bookmarkDirectoryURL = dir.appendingPathComponent(ViewController.bookmarkDirectory,
                                                                  isDirectory: true)
            
            /**
             *  Create the bookmarks directory (if it doesn't exist)
             */
            do {
                try FileManager.default.createDirectory(at: bookmarkDirectoryURL,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                
                /**
                 *  The URL for where the bookmark data was saved to.
                 */
                let bookmarkFileURL = bookmarkDirectoryURL.appendingPathComponent(bookmarkURL.lastPathComponent,
                                                                                  isDirectory: false)
                
                /**
                 *  Actually deleting the file.
                 */
                try FileManager.default.removeItem(at: bookmarkFileURL)
            } catch {
                
            }
        }
    }
}

extension ViewController: CommandExecutorDelegate {

    func commandExecutor(_ commandExecutor: CommandExecutor, receivedStdout stdout: String) {
        terminalView.writeOutput(sanitizeOutput(stdout))
    }
    func commandExecutor(_ commandExecutor: CommandExecutor, receivedStderr stderr: String) {
        terminalView.writeOutput(sanitizeOutput(stderr))
    }
    func commandExecutor(_ commandExecutor: CommandExecutor, didFinishDispatchWithExitCode exitCode: Int32) {
        terminalView.writePrompt()
        updateTitle()
    }

    private func sanitizeOutput(_ output: String) -> String {
        var output = output
        // Replace $HOME with "~"
        output = output.replacingOccurrences(of: DocumentManager.shared.activeDocumentsFolderURL.path, with: "~")
        // Sometimes, fileManager adds /private in front of the directory
        output = output.replacingOccurrences(of: "/private", with: "")
        return output
    }
}

extension ViewController: TerminalViewDelegate {

	func didEnterCommand(_ command: String) {

		HistoryManager.add(command)
		commandIndex = 0

        processCommand(command)
	}

    private func processCommand(_ command: String) {

        // Trim leading/trailing space
        let command = command.trimmingCharacters(in: .whitespacesAndNewlines)

        // Special case for clear
        if command == "clear" {
            terminalView.clearScreen()
            terminalView.writePrompt()
            return
        }

        // Special case for help
        if command == "help" || command == "?" {
            let commands = availableCommands().joined(separator: ", ")
            terminalView.writeOutput(commands)
            terminalView.writePrompt()
            return
        }
        
        // Dispatch the command to the executor
        executor.dispatch(command)
    }

}

extension ViewController: HistoryViewControllerDelegate {

	func didSelectCommand(command: String) {

		terminalView.currentCommand = command

	}

}

extension ViewController: PanelManager {

	var panels: [PanelViewController] {
		return [historyPanelViewController, scriptsPanelViewController, bookmarkPanelViewController]
	}

	var panelContentWrapperView: UIView {
		return contentWrapperView
	}

	var panelContentView: UIView {
		return terminalView
	}

	func didUpdatePinnedPanels() {

		savePanelStates()

	}

}

extension ViewController {

	@objc
	func savePanelStates() {

		let states = self.panelStates

		let encoder = PropertyListEncoder()

		guard let data = try? encoder.encode(states) else {
			return
		}

		UserDefaults.standard.set(data, forKey: "panelStates")

	}

	func getStatesFromDisk() -> [Int: PanelState]? {

		guard let data = UserDefaults.standard.data(forKey: "panelStates") else {
			return nil
		}

		let decoder = PropertyListDecoder()

		guard let states = try? decoder.decode([Int: PanelState].self, from: data) else {
			return nil
		}

		return states
	}

	func restorePanelStatesFromDisk() {

		let states: [Int: PanelState]

		if let statesFromDisk = getStatesFromDisk() {
			states = statesFromDisk
			restorePanelStates(states)

		}

	}

}
