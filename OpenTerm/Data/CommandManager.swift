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
	
}
