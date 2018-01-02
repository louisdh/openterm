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
	
	override func viewDidLoad() {
		super.viewDidLoad()

		printCommands()
		
		terminalView.processor = self
		
		updateTitle()
		setStdOut()
		setStdErr()

//		let exporter = CommandsExporter()
		
	}
	
	func printCommands() {
		
		let commands = String(cString: commandsAsString())
		
		let data = commands.data(using: .utf8)!
		
		let json = try! JSONSerialization.jsonObject(with: data, options: [])
		let arr = (json as! [String]).sorted()
		print(arr.joined(separator: "\n"))
		
	}
	
	func setStdOut() {
		
		let fileManager = DocumentManager.shared.fileManager
		let filePath = fileManager.currentDirectoryPath.appending("/.out.txt")
		
		try? fileManager.removeItem(atPath: filePath)

		if !fileManager.fileExists(atPath: filePath) {
			fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
		}
		
		let fileURL = URL(fileURLWithPath: filePath)
		
		guard let outHandle = try? FileHandle(forUpdating: fileURL) else {
			fatalError("Expected handle")
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
		
		let fileURL = URL(fileURLWithPath: filePath)
		
		guard let outHandle = try? FileHandle(forUpdating: fileURL) else {
			fatalError("Expected handle")
		}
		
		freopen(".err.txt", "a+", stderr)
		
	}

	func stringFromFILE(filePtr: UnsafeMutablePointer<FILE>) -> String {
		guard filePtr != nil else {
			return ""
		}
		// change the buffer size at your needs
		let buffer = [CChar](repeating: 0, count: 1024)
		var string = String()
		while fgets(UnsafeMutablePointer(mutating: buffer), Int32(buffer.count), filePtr) != nil {
			let read = String(cString: buffer)
			string += read
		}
		return string
	}
	
	func readFile(_ file: UnsafeMutablePointer<FILE>) {
		let bufsize = 4096
		let buffer = [CChar](repeating: 0, count: bufsize)

		// let stdin = fdopen(STDIN_FILENO, "r") it is now predefined in Darwin
		var buf = UnsafeMutablePointer(mutating: buffer)
		
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
	
}

extension ViewController: TerminalProcessor {
	
	@discardableResult
	func process(command: String) -> String {

		let fileManager = DocumentManager.shared.fileManager

		if command.hasPrefix("cd") {
			
			var arguments = command.split(separator: " ")
			arguments.removeFirst()
			
			if arguments.count == 1 {
				let folderName = arguments[0]
				
				if folderName == ".." {
					
					let dirPath = URL(fileURLWithPath: fileManager.currentDirectoryPath).deletingLastPathComponent()
					
					fileManager.changeCurrentDirectoryPath(dirPath.path)
					
				} else {
					
					let dirPath = fileManager.currentDirectoryPath.appending("/\(folderName)")
					
					fileManager.changeCurrentDirectoryPath(dirPath)
					
				}
				
				updateTitle()
				
				return ""
			} else {
				return ""
			}
			
		}
		
		setStdOut()
		setStdErr()

		ios_system(command.utf8CString)

		readFile(stdout)
		readFile(stderr)

		print("test")

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
