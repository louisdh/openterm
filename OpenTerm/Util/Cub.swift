//
//  Cub.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 03/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import Cub
import ios_system

public func cub(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {

    guard argc == 2 else {
        fputs("Usage: cub script.cub\n", thread_stderr)
        return 1
    }
    
    guard let fileName = argv?[1] else {
        fputs("Usage: cub script.cub\n", thread_stderr)
        return 1
    }
    
    let path = String(cString: fileName)

    guard FileManager.default.fileExists(atPath: path) else {
        fputs("Missing file \(path)\n", thread_stderr)
        return 1
    }
    
    let url = URL(fileURLWithPath: path)

    guard let data = FileManager.default.contents(atPath: url.path) else {
        fputs("Missing file \(path)\n", thread_stderr)
        return 1
    }

    guard let source = String.init(data: data, encoding: .utf8) else {
        fputs("Missing file \(path)\n", thread_stderr)
        return 1
    }
    
    let runner = Runner(logDebug: true, logTime: false)
    
    runner.registerExternalFunction(name: "print", argumentNames: ["input"], returns: false) { (arguments, callback) in
        
        for (name, arg) in arguments {
            fputs("\(arg)\n", thread_stdout)
        }
        
        callback(nil)
        return
    }

    runner.registerExternalFunction(name: "exec", argumentNames: ["command"], returns: true) { (arguments, callback) in

        var arguments = arguments

        guard let command = arguments.removeValue(forKey: "command") else {
            callback(.number(1))
            return
        }

        guard case let .string(commandStr) = command else {
            callback(.number(1))
            return
        }
        
        print("run command: \(commandStr)")

        executor.dispatch(commandStr, callback: { (code) in

            print("did run command: \(commandStr) -> \(code)")

            DispatchQueue.main.async {
                
                callback(.number(Double(code)))
            }
            
        })

    }
    
    runner.registerExternalFunction(name: "format", argumentNames: ["input", "arg"], returns: true) { (arguments, callback) in
        
        var arguments = arguments
        
        guard let input = arguments.removeValue(forKey: "input") else {
            callback(.string(""))
            return
        }
        
        guard case let .string(inputStr) = input else {
            callback(.string(""))
            return
        }
        
        var otherValues = arguments.values
        
        var varArgs = [CVarArg]()
        
        for value in otherValues {
            
            switch value {
            case .bool(let b):
                break
            case .number(let n):
                varArgs.append(n)
            case .string(let str):
                varArgs.append(str)
            case .struct:
                break
            }
            
        }
        
        let output = String(format: inputStr, arguments: varArgs)
        
        callback(.string(output))
        return
    }
    
    print("run")

    do {
        
        activeVC.terminalView.isExecutingScript = true
        
        runner.executionFinishedCallback = {
            
            print("executionFinishedCallback")
            
            DispatchQueue.main.async {
                
                activeVC.terminalView.isExecutingScript = false
//                activeVC.terminalView.isWaitingForCommand = false
                
                activeVC.commandExecutor(executor, didFinishDispatchWithExitCode: 0)
                
            }
            
        }
        
        try runner.run(source)
        
    } catch {
        return 1
    }

    
    return 0
}
