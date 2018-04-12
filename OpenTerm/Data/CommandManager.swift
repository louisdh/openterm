//
//  CommandManager.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 09/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

class CommandManager {
	
	let documentManager: DocumentManager
	
	var fileManager: FileManager {
		return documentManager.fileManager
	}

	static let shared = CommandManager(documentManager: .shared)

	init(documentManager: DocumentManager) {
		
		self.documentManager = documentManager
		
	}
	
	var scriptCommands: [String] {
		
		do {
			
			let documentsURLs = try fileManager.contentsOfDirectory(at: documentManager.scriptsURL, includingPropertiesForKeys: [], options: .skipsPackageDescendants)
			
			let pridelandURLs = documentsURLs.filter({ $0.pathExtension.lowercased() == "prideland" })
			
			return pridelandURLs.map({ ($0.lastPathComponent as NSString).deletingPathExtension })
			
		} catch {
			
			return []
		}
		
	}
	
	func script(named name: String) -> PridelandDocument? {
		
		guard scriptCommands.contains(name) else {
			return nil
		}
		
		let documentURL = documentManager.scriptsURL.appendingPathComponent("\(name).prideland")
		
		guard let fileWrapper = try? FileWrapper(url: documentURL, options: []) else {
			return nil
		}
		
		let document = PridelandDocument(fileURL: documentURL)
		
		do {
			try document.load(fromContents: fileWrapper, ofType: "prideland")
		} catch {
			return nil
		}
		
		return document
	}
	
	func description(for command: String) -> String? {
		
		if let scriptDocument = script(named: command) {
			return scriptDocument.metadata?.description ?? ""
		}
		
		return CommandManager.descriptions[command]
	}
	
	static private let descriptions = ["awk": "a powerful method for processing or analyzing text files",
									   "cat": "read files",
									   "cd": "change the current directory",
									   "chflags": "change a file or folder's flags",
									   "chksum": "display file checksums and block counts",
									   "compress": "compress files",
									   "cp": "copy a file or folder",
									   "credits": "display the OpenTerm credits",
									   "cub": "execute a Cub script",
									   "curl": "transfer data from or to a server",
									   "date": "get the current date and time",
									   "dig": "a flexible tool for interrogating DNS name servers",
									   "du": "display disk usage statistics",
									   "echo": "display message on screen"]
	// TODO: add descriptions for all commands.
	
}
