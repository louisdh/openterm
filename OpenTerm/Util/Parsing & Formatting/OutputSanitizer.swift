//
//  OutputSanitizer.swift
//  OpenTerm
//
//  Created by iamcdowe on 2/6/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

class OutputSanitizer {

	static func sanitize(_ output: NSMutableString) {
		// Replace $HOME with "~"
		output.replaceOccurrences(of: DocumentManager.shared.activeDocumentsFolderURL.path, with: "~", options: .caseInsensitive, range: NSRange(location: 0, length: output.length))

		// Sometimes, fileManager adds /private in front of the directory
		output.replaceOccurrences(of: "/private", with: "", options: .caseInsensitive, range: NSRange(location: 0, length: output.length))
	}
}
