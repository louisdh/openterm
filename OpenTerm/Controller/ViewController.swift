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

let executor = CommandExecutor()

var activeVC: ViewController!

class ViewController: UIViewController {

	@IBOutlet weak var terminalView: TerminalView!

	@IBOutlet weak var contentWrapperView: UIView!

	var historyViewController: HistoryViewController!
	var historyPanelViewController: PanelViewController!

	var scriptsViewController: ScriptsViewController!
	var scriptsPanelViewController: PanelViewController!
    
    var bookmarkViewController: BookmarkViewController!
    var bookmarkPanelViewController: PanelViewController!

	override func viewDidLoad() {
		super.viewDidLoad()
        
        activeVC = self

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

        replaceCommand("open-url", mangleFunctionName("openUrl"), true)
        replaceCommand("share", mangleFunctionName("shareFile"), true)
        replaceCommand("pbcopy", mangleFunctionName("pbcopy"), true)
        replaceCommand("pbpaste", mangleFunctionName("pbpaste"), true)
        replaceCommand("cub", mangleFunctionName("cub"), true)

        // Call reloadData for the added commands.
        terminalView.autoCompleteManager.reloadData()
        
        shareFileViewController = self // shareFile needs to know which view controller to present share sheet from

		setSSLCertIfNeeded()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.terminalView.becomeFirstResponder()

	}

    func mangleFunctionName(_ functionName: String) -> String {
        // This works because all functions have the same signature:
        // (argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32
        // The first part is the class name: _T0 + length + name. To change if not "OpenTerm"
        return "_T08OpenTerm" + String(functionName.count) + functionName + "s5Int32VAD4argc_SpySpys4Int8VGSgGSg4argvtF"
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

        }, completion: { (_) in

			if !self.allowFloatingPanels {
				self.closeAllFloatingPanels()
			}

			if !self.allowPanelPinning {
				self.closeAllPinnedPanels()
			}

		})

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

    @objc func completeCommand() {
        // When tab key is pressed, insert first completion, if we have one.
        if let firstCompletion = terminalView.autoCompleteManager.completions.first {
            terminalView.insertCompletion(firstCompletion)
        }
    }

	override var keyCommands: [UIKeyCommand]? {

		let prevCmd = UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(selectPreviousCommand), discoverabilityTitle: "Previous command")

		let nextCmd = UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(selectNextCommand), discoverabilityTitle: "Next command")

		let clearBufferCmd = UIKeyCommand(input: "K", modifierFlags: .command, action: #selector(clearBufferCommand), discoverabilityTitle: "Clear Buffer")

//		let homeCmd = UIKeyCommand(input: "A", modifierFlags: .control, action: #selector(selectCommandHome), discoverabilityTitle: "Home")

		let endCmd = UIKeyCommand(input: "E", modifierFlags: .control, action: #selector(selectCommandEnd), discoverabilityTitle: "End")

        let tabCmd = UIKeyCommand(input: "\t", modifierFlags: [], action: #selector(completeCommand), discoverabilityTitle: "Complete")

		return [
			prevCmd,
			nextCmd,
			clearBufferCmd,
//			homeCmd,
            tabCmd,
			endCmd
		]
	}

}

extension ViewController: UIDocumentPickerDelegate {

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

		guard let firstFolder = urls.first else {
			return
		}

        self .changeDirectoryToURL(url: firstFolder)
	}

}

extension ViewController: BookmarkViewControllerDelegate {
    
    /// Changes the current directory to the passed url.
    /// - Note: Only urls that contain the required access permissions will work..
    ///
    /// - Parameter bookmarkURL: The bookmark that was selected.
    func changeDirectoryToURL(url: URL) {
        
        //  Access the URL
        _ = url.startAccessingSecurityScopedResource()
        
        //  Change the directory to the path.
        DocumentManager.shared.fileManager.changeCurrentDirectoryPath(url.path)
        
        // Update the title.
        self.updateTitle()
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
        DispatchQueue.main.async {
            self.terminalView.writePrompt()
            self.updateTitle()
        }
    }

    internal func sanitizeOutput(_ output: String) -> String {
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
