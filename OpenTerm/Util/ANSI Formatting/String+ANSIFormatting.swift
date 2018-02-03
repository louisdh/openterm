//
//  String+ANSIColors.swift
//  OpenTerm
//
//  Created by Ian McDowell on 1/31/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

extension String {

    private static let escapeSequenceRegex = try! NSRegularExpression(pattern: "\u{001B}\\[(.*?)m", options: [])

    /// Take the contents of the string and add attributes based on ANSI escape codes
    func formattedAttributedString(withTextState textState: inout ANSITextState) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()

        var position = 0; let length = self.count
        while position < length {
            // In each iteration, process some amount of text, and append to this.
            var processed: Int

            // Find next escape sequence
            let range = NSRange.init(location: position, length: length - position)
            let match = String.escapeSequenceRegex.firstMatch(in: self, options: [], range: range)
            if let match = match {
                processed = match.range.location - position
            } else {
                processed = length - position
            }

            // Add text in processed portion to the attributed string
            let processedRange = Range(NSRange(location: position, length: processed), in: self)!
            let newString = NSAttributedString(string: String(self[processedRange]), attributes: textState.attributes)
            attributedString.append(newString)

            // Update text state with escape codes found in match from above
            if let match = match {
                let valueRange = match.range(at: 1)
                let escapeCodes = String(self[Range(valueRange, in: self)!])
                textState.parse(escapeCodes: escapeCodes)
                processed += match.range.length
            }

            position += processed
        }
        return attributedString
    }
}
