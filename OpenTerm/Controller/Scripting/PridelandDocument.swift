//
//  PridelandDocument.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 06/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

enum PridelandDocumentError: Error {
	case invalidDocument
}

class PridelandDocument: UIDocument {
	
	var text = ""
	
	var metadata: PridelandMetadata?
	
	override init(fileURL url: URL) {
		super.init(fileURL: url)
		
	}
	
	override func contents(forType typeName: String) throws -> Any {
		
		let fileWrapper = FileWrapper(directoryWithFileWrappers: [:])
	
		let contentsFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
		contentsFileWrapper.preferredFilename = "contents"
		
		guard let textData = text.data(using: .utf8) else {
			throw PridelandDocumentError.invalidDocument
		}
		
		let cubFileWrapper = FileWrapper(regularFileWithContents: textData)
		cubFileWrapper.preferredFilename = "1.cub"
		
		contentsFileWrapper.addFileWrapper(cubFileWrapper)
		fileWrapper.addFileWrapper(contentsFileWrapper)
		
		guard let metadata = metadata else {
			throw PridelandDocumentError.invalidDocument
		}
		
		let decoder = PropertyListEncoder()
		decoder.outputFormat = .xml
		
		guard let metadataData = try? decoder.encode(metadata) else {
			throw PridelandDocumentError.invalidDocument
		}
		
		let metadataFileWrapper = FileWrapper(regularFileWithContents: metadataData)
		metadataFileWrapper.preferredFilename = "metadata.plist"
		fileWrapper.addFileWrapper(metadataFileWrapper)
		
		return fileWrapper
	}
	
	override func load(fromContents contents: Any, ofType typeName: String?) throws {
		
		guard let fileWrapper = contents as? FileWrapper else {
			throw PridelandDocumentError.invalidDocument
		}
		
		guard let wrappers = fileWrapper.fileWrappers else {
			throw PridelandDocumentError.invalidDocument
		}
		
		let contentsWrapper = wrappers["contents"]
		
		guard let cubContentsWrapper = contentsWrapper?.fileWrappers?["1.cub"] else {
			throw PridelandDocumentError.invalidDocument
		}
		
		guard let textData = cubContentsWrapper.regularFileContents else {
			throw PridelandDocumentError.invalidDocument
		}
		
		guard let text = String(data: textData, encoding: .utf8) else {
			throw PridelandDocumentError.invalidDocument
		}
		
		guard let metadataData = wrappers["metadata.plist"]?.regularFileContents else {
			throw PridelandDocumentError.invalidDocument
		}
		
		let decoder = PropertyListDecoder()
		
		guard let metadata = try? decoder.decode(PridelandMetadata.self, from: metadataData) else {
			throw PridelandDocumentError.invalidDocument
		}
		
		self.text = text
		self.metadata = metadata
		
	}
	
}

struct PridelandMetadata: Codable, Equatable {
	
	let name: String
	let description: String
	let hueTint: Double
	
}
