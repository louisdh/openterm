//
//  FileLinks.swift
//  OpenTerm
//
//  Created by Anders Borum on 05/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

extension NSAttributedString {
    public func withFilesAsLinks() -> NSAttributedString {
        let text = string
        let mutable = self.mutableCopy() as! NSMutableAttributedString
        
        // read all files to have easy access
        let manager = FileManager.default
        var files = [String:[String]]() // key is first word of filename, value is entire filename relative to current dir
        do {
            for filename in try manager.contentsOfDirectory(atPath: manager.currentDirectoryPath) {
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
                        let url = URL(fileURLWithPath: manager.currentDirectoryPath).appendingPathComponent(filename)
                        let attrs = [NSAttributedStringKey.link: url,
                                     NSAttributedStringKey.underlineStyle: 1] as [NSAttributedStringKey : Any]
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
    
    var dirParts = ((directory as NSString).standardizingPath as NSString).pathComponents
    var pathParts = ((filename as NSString).standardizingPath as NSString).pathComponents
    
    // head is grown from the start and tail from the end
    var head = ""
    var tail = ""
    
    while !dirParts.isEmpty || !pathParts.isEmpty {
        if dirParts.isEmpty {
            // we have no more dir, which means we must specify relative
            let path = pathParts.removeFirst()
            tail = (tail as NSString).appendingPathComponent(path)
            continue
            
        } else if(pathParts.isEmpty) {
            // we have no more path, which means we must go out
            dirParts.removeFirst()
            head = (head as NSString).appendingPathComponent("..")
            continue
        }
        
        let dir = dirParts.isEmpty ? "" : dirParts.removeFirst()
        let path = pathParts.isEmpty ? "" : pathParts.removeFirst()
        
        if dir == path { continue }
        
        // step out and step in
        head = (head as NSString).appendingPathComponent("..")
        tail = (tail as NSString).appendingPathComponent(path)
    }
    
    return (head as NSString).appendingPathComponent(tail)
}
