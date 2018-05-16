//
//  FileManager+Download.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 16/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

extension FileManager {
	
	@discardableResult
	func downloadAllFromCloud(at url: URL) throws -> Bool {
		
		if url.pathExtension.lowercased() == "icloud" {
			try self.startDownloadingUbiquitousItem(at: url)
			return true
		}
		
		guard url.hasDirectoryPath else {
			return false
		}
		
		let contents = try self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
		
		var foundCloudFile = false
		
		for content in contents {
			
			if content.pathExtension.lowercased() == "icloud" {
				
				try self.startDownloadingUbiquitousItem(at: content)
				foundCloudFile = true
				
			} else {
				
				if try downloadAllFromCloud(at: content) {
					foundCloudFile = true
				}
				
			}
			
		}
		
		return foundCloudFile
	}
	
}
