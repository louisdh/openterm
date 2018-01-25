//
//  Command.swift
//  OpenTerm
//
//  Created by Adrian Labbé on 24.01.18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

/// Class template for writing a command.
class Command {
    
    /// All commands per name.
    static let allAppCommands: [String:Command] = ["helloworld":HelloWorld()]
    
    /// Text view where print text.
    static var textView: UITextView?
    
    /// Print to `textView`.
    ///
    /// - Parameters:
    ///     - text: Text to add to the textView.
    func printtv(_ item: Any) {
        guard let textView = Command.textView else { return }
        textView.text = textView.text+"\(item)"
    }
    
    /// Print to `textView` with a newline.
    ///
    /// - Parameters:
    ///     - text: Text to add to the textView.
    func printlntv(_ item: Any) {
        printtv("\(item)\n")
    }
    
    /// Subclass and put code here.
    ///
    /// Call super's function to put a newline at start.
    /// - Parameters:
    ///     - arguments: Arguments sent.
    /// - Returns: Return code.
    func execute(withArguments arguments: [String]) -> Int {
        printtv("\n")
        
        return 0
    }
}
