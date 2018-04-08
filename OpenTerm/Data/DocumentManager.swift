//
//  DocumentManager.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 07/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import UIKit
import ios_system

class DocumentManager {

	static let shared = DocumentManager()

	let fileManager: FileManager

	init(fileManager: FileManager = .default) {

		self.fileManager = fileManager

		let baseURL = self.activeDocumentsFolderURL

		if !fileManager.fileExists(atPath: baseURL.path) {
			try? fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true, attributes: nil)
		}

		fileManager.changeCurrentDirectoryPath(baseURL.path)
		ios_setMiniRoot(baseURL.path)

	}

	private let ICLOUD_IDENTIFIER = "iCloud.com.silverfox.Terminal"

	private var localDocumentsURL: URL {
		return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
	}

	private var cloudDocumentsURL: URL? {

		guard iCloudAvailable else {
			return nil
		}

		let ubiquityContainerURL = fileManager.url(forUbiquityContainerIdentifier: ICLOUD_IDENTIFIER)

		return ubiquityContainerURL?.appendingPathComponent("Documents")
	}

	var currentDirectoryURL: URL {
		get {
			return URL(fileURLWithPath: fileManager.currentDirectoryPath).standardizedFileURL
		}
		set {
			fileManager.changeCurrentDirectoryPath(newValue.standardizedFileURL.path)
		}
	}

	var activeDocumentsFolderURL: URL {

		if let cloudDocumentsURL = cloudDocumentsURL {
			return cloudDocumentsURL
		} else {
			return localDocumentsURL
		}
	}

	var iCloudAvailable: Bool {
		return fileManager.ubiquityIdentityToken != nil
	}

}
