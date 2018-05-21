//
//  PridelandOverview.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 21/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

enum PridelandOverviewError: Error {
	case invalidFileWrapper
	case invalidFileWrappers
	case noMetadata
	case invalidMetadata
}

struct PridelandOverview: Equatable {
	
	let url: URL
	let metadata: PridelandMetadata
	
	init(url: URL, fileWrapper: FileWrapper) throws {
		
		guard fileWrapper.isDirectory else {
			throw PridelandOverviewError.invalidFileWrapper
		}
		
		guard let wrappers = fileWrapper.fileWrappers else {
			throw PridelandOverviewError.invalidFileWrappers
		}
		
		guard let metadataData = wrappers["metadata.plist"]?.regularFileContents else {
			throw PridelandOverviewError.noMetadata
		}
		
		let decoder = PropertyListDecoder()
		
		guard let metadata = try? decoder.decode(PridelandMetadata.self, from: metadataData) else {
			throw PridelandOverviewError.invalidMetadata
		}
		
		self.metadata = metadata
		self.url = url
		
	}
	
}
