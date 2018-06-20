//
//  Share.swift
//  OpenTerm
//
//  Created by Anders Borum on 28/01/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import ios_system

public weak var shareFileViewController: UIViewController?

@_cdecl("shareFile")
public func shareFile(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
	var itemsToShare = [Any]()

	var bytes = [Int8]()
	
	if Int(argc) == 1 {
		
		// share text from stdin when present
		while stdin != thread_stdin {
			var byte: Int8 = 0
			let count = read(fileno(thread_stdin), &byte, 1)
			guard count == 1 else {
				break
			}
			bytes.append(byte)
		}
	}
	
	let data = Data(bytes: bytes, count: bytes.count)
	if data.count > 0 {
		let string = String(data: data, encoding: .utf8) ?? ""
		if string.isEmpty {
			fputs("Unable to read string from standard input\n", thread_stderr)
			return 1
		}
		itemsToShare.append(string)
	}

	// all arguments are files we want to share
	for k in 1..<Int(argc) {
		let path = String(cString: argv![k]!)
		guard FileManager.default.fileExists(atPath: path) else {
			fputs("Missing file \(path)\n", thread_stderr)
			return 1
		}
		let url = URL(fileURLWithPath: path)
		itemsToShare.append(url)
	}

	// if there is nothing to share we output usage
	if itemsToShare.isEmpty {
		fputs("""
usage: share [file1] [file2]

shows a share sheet with all files as well as any text from standard input.

""", stderr)
		return 1
	}

	// present view controller
	guard let vc = shareFileViewController else {
		fputs("Unknown shareFileViewController\n", thread_stderr)
		return 1
	}

	let sharesheet = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
	sharesheet.popoverPresentationController?.sourceView = vc.view
	vc.present(sharesheet, animated: true, completion: nil)

	return 0
}
