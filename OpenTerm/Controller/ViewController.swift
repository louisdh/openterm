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
		
		terminalView.processor = self
		terminalView.delegate = self
		
		updateTitle()
		setStdOut()
		setStdErr()
		
		NotificationCenter.default.addObserver(self, selector: #selector(didDismissKeyboard), name: .UIKeyboardDidHide, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)

        initializeEnvironment()
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
			
		}) { (context) in
			
			if !self.allowFloatingPanels {
				self.closeAllFloatingPanels()
			}
			
			if !self.allowPanelPinning {
				self.closeAllPinnedPanels()
			}
			
		}
		
	}
	
	var didRequestReview = false
	
	@objc
	func didDismissKeyboard() {
		
		guard !didRequestReview else {
			return
		}
		
		if historyViewController.commands.count > 5 {
			SKStoreReviewController.requestReview()
			didRequestReview = true
		}
		
	}
	
	@objc
	func applicationDidEnterBackground() {

		savePanelStates()
		
	}
	
	@IBAction func showHistory(_ sender: UIBarButtonItem) {
		
		historyPanelViewController.modalPresentationStyle = .popover
		historyPanelViewController.popoverPresentationController?.barButtonItem = sender
		
		historyPanelViewController.popoverPresentationController?.backgroundColor = historyViewController.view.backgroundColor
		present(historyPanelViewController, animated: true, completion: nil)
		
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
	
	func setStdOut() {
		
		let fileManager = DocumentManager.shared.fileManager
		let filePath = NSTemporaryDirectory().appending("out.txt")
		
		try? fileManager.removeItem(atPath: filePath)

		if !fileManager.fileExists(atPath: filePath) {
			fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
		}
		
		freopen(filePath.toCString(), "a+", stdout)

	}
	
	func setStdErr() {
		
		let fileManager = DocumentManager.shared.fileManager
		let filePath = NSTemporaryDirectory().appending("err.txt")
		
		try? fileManager.removeItem(atPath: filePath)
		
		if !fileManager.fileExists(atPath: filePath) {
			fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
		}
		
		freopen(filePath.toCString(), "a+", stderr)
		
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

    @objc func clearBufferCommand() {
        terminalView.clearBuffer()
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

extension ViewController: TerminalProcessor {
	
	@discardableResult
	func process(command: String) -> String {

		let fileManager = DocumentManager.shared.fileManager

		if command == "help" || command == "?" {
			return availableCommands().joined(separator: ", ")
		}
		
		setStdOut()
		setStdErr()

		ios_system(command.utf8CString)

        updateTitle()
		readFile(stdout)
		readFile(stderr)

		let errFilePath = NSTemporaryDirectory().appending("err.txt")

		if let data = fileManager.contents(atPath: errFilePath) {
			if let errStr = String(data: data, encoding: .utf8) {
                if !errStr.isEmpty {
                    return errStr
                }
			}
		}
		
		let filePath = NSTemporaryDirectory().appending("out.txt")

		if let data = fileManager.contents(atPath: filePath) {
			return String(data: data, encoding: .utf8) ?? ""
		}
		
		return ""
	}
	
}
