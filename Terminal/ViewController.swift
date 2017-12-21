//
//  ViewController.swift
//  Terminal
//
//  Created by Louis D'hauwe on 07/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var terminalView: TerminalView!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		terminalView.processor = self
		
		updateTitle()
	
		process(command: "cd Root")
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
		
		return "-bash: \(command): command not found"
	}
	
}
