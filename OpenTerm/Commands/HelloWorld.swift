//
//  HelloWorld.swift
//  OpenTerm
//
//  Created by Adrian Labbé on 24.01.18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

/// Test builtin command.
class HelloWorld: Command {
    
    /// Prints Hello World!.
    override func execute(withArguments arguments: [String]) -> Int {
        
        _ = super.execute(withArguments: arguments)
        
        if arguments.contains("--argv") || arguments.contains("-argv") || arguments.contains("-a") {
            // Print given arguments
            printlntv(arguments)
            return 0
        } else if arguments.contains("--help") || arguments.contains("-help") || arguments.contains("-h") {
            printtv("Prints Hello World!\n\n--argv, -a: Print arguments")
        } else if arguments.count > 0 {
            printlntv("Invalid arguments!")
            return 1
        }
            
        printlntv("Hello World!")
            
        return 0
            
        
    }
    
}
