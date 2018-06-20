//
//  FileLinks.swift
//  OpenTerm
//
//  Created by Anders Borum on 05/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

extension URL {
	
	// Return URL in the same directory as this one that does not exist, by appending -1 or -2 to part of filename before .ext
	// The original url might be returned if there is nothing at this location.
	public func unused() -> URL {
		let manager = FileManager.default
		if !manager.fileExists(atPath: path) { return self }
		
		let directory = self.deletingLastPathComponent()
		let ext = self.pathExtension

		// remove anything from - and to the end
		var basename = self.deletingPathExtension().lastPathComponent
		if let range = basename.range(of: "-", options: .backwards) {
			basename.removeSubrange(range.lowerBound ... basename.endIndex)
		}
		
		// keep counting up until we have unused filename
		var index = 1
		while true {
			let filename = "\(basename)-\(index).\(ext)"
			let url = directory.appendingPathComponent(filename)
			if !manager.fileExists(atPath: url.path) {
				return url
			}
			
			index += 1
		}
	}
	
}

extension NSAttributedString {
	
	public func withFilesAsLinks(currentDirectory: String) -> NSAttributedString {
        let text = string
        let mutable = self.mutableCopy() as! NSMutableAttributedString
        
        // read all files to have easy access
        let manager = FileManager.default
        var files = [String: [String]]() // key is first word of filename, value is entire filename relative to current dir
		
		do {
			for filename in try manager.contentsOfDirectory(atPath: currentDirectory) {
                if let word = filename.components(separatedBy: " ").first {
                    var array = files[word] ?? [String]()
                    array.append(filename)
                    files[word] = array
                }
            }
        } catch {
			
        }
        
        let whitespace = CharacterSet.whitespacesAndNewlines
        
        var pos = text.startIndex
        while pos < text.endIndex {
            let range = text.rangeOfCharacter(from: whitespace, options: [], range: Range(uncheckedBounds: (lower: pos, upper: text.endIndex)))
            let endWord = range?.lowerBound ?? text.endIndex
            let word = String(text[pos..<endWord])
            
            // run through filenames checking if anything matches from pos and forward
            let filenames = files[word] ?? []
            var found = false
            for filename in filenames {
                if let range = text.range(of: filename, options: [.anchored], range: Range(uncheckedBounds: (lower: pos, upper: text.endIndex))) {
                    found = range.lowerBound == pos
                    if found {
                        // mark as link
                        let url = URL(fileURLWithPath: currentDirectory).appendingPathComponent(filename)
						let attrs: [NSAttributedStringKey: Any] = [.link: url,
																   .underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
						
                        let nsRange = NSRange(location: range.lowerBound.encodedOffset,
                                              length: range.upperBound.encodedOffset -  range.lowerBound.encodedOffset)
                        mutable.addAttributes(attrs, range: nsRange)

                        pos = range.upperBound
                        break
                    }
                }
            }
            
            if !found {
                pos = range?.upperBound ?? text.endIndex
            }
        }
        
        return mutable
    }
}

// calculate path for filename relative to directory inserting .. as needed
func relative(filename: String, to directory: String) -> String {
    
    var dirParts = URL(fileURLWithPath: directory).standardizedFileURL.pathComponents
	var pathParts = URL(fileURLWithPath: filename).standardizedFileURL.pathComponents
    
    // head is grown from the start and tail from the end
	var head = URL(fileURLWithPath: "")
    var tail = URL(fileURLWithPath: "")
    
    while !dirParts.isEmpty || !pathParts.isEmpty {
        if dirParts.isEmpty {
            // we have no more dir, which means we must specify relative
            let path = pathParts.removeFirst()
            tail = tail.appendingPathComponent(path)
            continue
            
        } else if pathParts.isEmpty {
            // we have no more path, which means we must go out
            dirParts.removeFirst()
			head = head.appendingPathComponent("..")
            continue
        }
        
        let dir = dirParts.isEmpty ? "" : dirParts.removeFirst()
        let path = pathParts.isEmpty ? "" : pathParts.removeFirst()
        
        if dir == path { continue }
        
        // step out and step in
        head = head.appendingPathComponent("..")
        tail = tail.appendingPathComponent(path)
    }
	
	var result = tail.relativePath
	if head.relativePath != "." {
		result = head.appendingPathComponent(tail.relativePath).relativePath
	}
	
	// skip leading ./
	if let cwdPrefix = result.range(of: "./", options: .anchored) {
		result.removeSubrange(cwdPrefix)
	}

	return result
}

extension UITextView {
	func range(_ textRange: UITextRange) -> NSRange {
		let start = offset(from: beginningOfDocument, to: textRange.start)
		let end = offset(from: textRange.start, to: textRange.end)
		let range = NSRange(location: start, length: end - start)
		return range
	}
}
