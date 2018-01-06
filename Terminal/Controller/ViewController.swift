//
//  ViewController.swift
//  Terminal
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
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		historyViewController = storyboard.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
		historyViewController.delegate = self
		
		historyPanelViewController = PanelViewController(with: historyViewController, in: self)
		
		printCommands()
		
		terminalView.processor = self
		terminalView.delegate = self
		
		updateTitle()
		setStdOut()
		setStdErr()
		
		NotificationCenter.default.addObserver(self, selector: #selector(didDismissKeyboard), name: .UIKeyboardDidHide, object: nil)
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.terminalView.becomeFirstResponder()
		
	}
	
	@objc func didDismissKeyboard() {
		
		SKStoreReviewController.requestReview()
		
	}
	
	@IBAction func showHistory(_ sender: UIBarButtonItem) {
		
		historyPanelViewController.modalPresentationStyle = .popover
		historyPanelViewController.popoverPresentationController?.barButtonItem = sender
		
		historyPanelViewController.popoverPresentationController?.backgroundColor = historyViewController.view.backgroundColor
		present(historyPanelViewController, animated: true, completion: nil)
		
	}
	
	func availableCommands() -> [String] {

		let commands = String(cString: commandsAsString())
		
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
		
		arr.append("cd")
		arr.append("clear")
		arr.append("help")

		return arr.sorted()
	}
	
	func printCommands() {
		
		print(availableCommands().joined(separator: "\n"))
		
	}
	
	func setStdOut() {
		
		let fileManager = DocumentManager.shared.fileManager
		let filePath = fileManager.currentDirectoryPath.appending("/.out.txt")
		
		try? fileManager.removeItem(atPath: filePath)

		if !fileManager.fileExists(atPath: filePath) {
			fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
		}
		
		freopen(".out.txt", "a+", stdout)

	}
	
	func setStdErr() {
		
		let fileManager = DocumentManager.shared.fileManager
		let filePath = fileManager.currentDirectoryPath.appending("/.err.txt")
		
		try? fileManager.removeItem(atPath: filePath)
		
		if !fileManager.fileExists(atPath: filePath) {
			fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
		}
		
		freopen(".err.txt", "a+", stderr)
		
	}
	
	func readFile(_ file: UnsafeMutablePointer<FILE>) {
		let bufsize = 4096
		let buffer = [CChar](repeating: 0, count: bufsize)

		let buf = UnsafeMutablePointer(mutating: buffer)
		
		while (fgets(buf, Int32(bufsize-1), file) != nil) {
			let out = String(cString: buf)
			print(out)
		}
		buf.deinitialize()
	}
	
	func updateTitle() {
		
		let url = URL(fileURLWithPath: DocumentManager.shared.fileManager.currentDirectoryPath)
		self.title = url.lastPathComponent

	}
	
	var commandIndex = 0
	
	@objc func selectPreviousCommand() {
		
		guard commandIndex < historyViewController.commands.count else {
			return
		}
		
		commandIndex += 1

		terminalView.currentCommand = historyViewController.commands.reversed()[commandIndex - 1]

	}
	
	@objc func selectNextCommand() {
		
		guard commandIndex > 0 else {
			return
		}
		
		commandIndex -= 1
		
		if commandIndex == 0 {
			terminalView.currentCommand = ""
		} else {
			terminalView.currentCommand = historyViewController.commands.reversed()[commandIndex - 1]
		}

	}
	
	override var keyCommands: [UIKeyCommand]? {
		let prevCmd = UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(selectPreviousCommand))

		let nextCmd = UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(selectNextCommand))

		
		return [prevCmd, nextCmd]
	}
	
}

extension ViewController: TerminalViewDelegate {
	
	func didEnterCommand(_ command: String) {

		historyViewController.addCommand(command)
		commandIndex = 0
		
	}

}

extension ViewController: HistoryViewControllerDelegate {
	
	func didSelectCommand(command: String) {
		
		terminalView.currentCommand = command
		
	}
	
}

extension ViewController: PanelManager {

	var panels: [PanelViewController] {
		return [historyPanelViewController]
	}
	
	var panelContentWrapperView: UIView {
		return contentWrapperView
	}
	
	var panelContentView: UIView {
		return terminalView
	}

}

extension ViewController {
	
	func cd(command: String) -> String {
		
		let fileManager = DocumentManager.shared.fileManager
		
		var arguments = command.split(separator: " ")
		arguments.removeFirst()
		
		if arguments.count == 1 {
			let folderName = arguments[0]
			
			if folderName == ".." {
				
				let dirPath = URL(fileURLWithPath: fileManager.currentDirectoryPath).deletingLastPathComponent()
				
				if dirPath.lastPathComponent == "iCloud~com~silverfox~Terminal" {
					return ""
				}
				
				fileManager.changeCurrentDirectoryPath(dirPath.path)
				
			} else if folderName.hasPrefix("/") {
				
				guard let documents = DocumentManager.shared.activeDocumentsFolderURL else {
					return ""
				}
				
				let dirPath = documents.appendingPathComponent(String(folderName)).path
				
				fileManager.changeCurrentDirectoryPath(dirPath)
				
			} else {
				
				let dirPath = fileManager.currentDirectoryPath.appending("/\(folderName)")
				
				fileManager.changeCurrentDirectoryPath(dirPath)
				
			}
			
			return ""
		} else {
			return ""
		}
		
	}
	
}

extension ViewController: TerminalProcessor {
	
	@discardableResult
	func process(command: String) -> String {

		let fileManager = DocumentManager.shared.fileManager

		if command == "help" || command == "?" {
			return availableCommands().joined(separator: "\n")
		}
		
		if command.hasPrefix("cd") {
			
			let result = cd(command: command)
			
			updateTitle()

			return result
		}
		
		setStdOut()
		setStdErr()

		ios_system(command.utf8CString)

		readFile(stdout)
		readFile(stderr)

		let errFilePath = fileManager.currentDirectoryPath.appending("/.err.txt")

		if let data = fileManager.contents(atPath: errFilePath) {
			if let errStr = String(data: data, encoding: .utf8) {
				
				let filtered = errStr.replacingOccurrences(of: "Command after parsing: ", with: "")
				
				if !filtered.isEmpty {
					return filtered
				}
				
			}
		}
		
		let filePath = fileManager.currentDirectoryPath.appending("/.out.txt")

		if let data = fileManager.contents(atPath: filePath) {
			return String(data: data, encoding: .utf8) ?? ""
		}
		
		return ""
	}
	
}
