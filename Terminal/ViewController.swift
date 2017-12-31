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

		terminalView.processor = self
		
		updateTitle()
		setStdOut()

		print("test")

		ios_system("ls -l".utf8CString)

		readFile()

//		ios_system("ls -l".utf8CString)
//
//		readFile()
		
		print("test")
		
//		fclose(stdout)
		
//		stderr = file!

//		process(command: "cd Root")

//		process(command: "mkdir testing")
//		process(command: "cat test.svg")

//		ios_system(.UTF8CString)
		
//		let output = fileManager.contents(atPath: filePath)
		
//		let readFileHandle = FileHandle(fileDescriptor: stdout.pointee._r)
//		let data = readFileHandle.readDataToEndOfFile()
		
//		let output = stringFromFILE(filePtr: stdout)
//		readFile()
		
//		ios_system("cd ..".UTF8CString)
//		ios_system("cd ..".UTF8CString)
//		ios_system("ls -l".UTF8CString)
		
//		print("test")
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

//		guard let file = freopen("".utf8CString, "a+", outHandle.fileDescriptor) else {
//			fatalError("Expected file")
//		}
//
//		stdout = file
//
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
	
	func readFile() {
		let bufsize = 4096
		let buffer = [CChar](repeating: 0, count: bufsize)

		// let stdin = fdopen(STDIN_FILENO, "r") it is now predefined in Darwin
		var buf = UnsafeMutablePointer(mutating: buffer)
		
		while (fgets(buf, Int32(bufsize-1), stdout) != nil) {
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
			}
			
		}
		
		setStdOut()
		
		ios_system(command.utf8CString)

		readFile()

		print("test")
		
		let filePath = fileManager.currentDirectoryPath.appending("/.out.txt")

		let data = fileManager.contents(atPath: filePath)
		
		return String(data: data!, encoding: .utf8)!

		return ""
		
		if command == "" {
			return ""
		}
		
		if command == "ls" {
		
			do {
				
				let files = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: fileManager.currentDirectoryPath), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
				
//				let files = try fileManager.contentsOfDirectory(atPath: fileManager.currentDirectoryPath)
				
				return files.map{ $0.lastPathComponent }.joined(separator: "\n")

			} catch {
				
			}
			
		}
		
		if command.hasPrefix("mkdir") {

			var arguments = command.split(separator: " ")
			arguments.removeFirst()
			
			if arguments.count == 1 {
				let folderName = arguments[0]
				
				let dirPath = fileManager.currentDirectoryPath.appending("/\(folderName)")
				
				do {
					try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: false, attributes: nil)
					return ""
				} catch {
					
				}
			}
			
		}
		
		if command.hasPrefix("touch") {
			
			var arguments = command.split(separator: " ")
			arguments.removeFirst()
			
			if arguments.count >= 1 {
				
				for fileName in arguments {
					
					let filePath = fileManager.currentDirectoryPath.appending("/\(fileName)")
					
					
					let succeed = fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
					
					if !succeed {
						return "Couldn't create file \"\(fileName)\""
					}
					
				}
				
				return ""
				
			}
			
		}
		
	
		
		return "-bash: \(command): command not found"
	}
	
}
