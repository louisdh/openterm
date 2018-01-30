//
//  ScriptExecutorCommand.swift
//  OpenTerm
//
//  Created by iamcdowe on 1/30/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

/// Implementation for running a script.
class ScriptExecutorCommand: CommandExecutorCommand {

    let script: Script
    let arguments: [String]
    init(script: Script, arguments: [String]) {
        self.script = script; self.arguments = arguments
    }

    func run() throws -> ReturnCode {
        let commands = try script.runnableCommands(withArgs: self.arguments)

        var returnCode: Int32 = 0
        for command in commands {
            let executor = CommandExecutor.executorCommand(forCommand: command)
            returnCode = try executor.run()
            if returnCode != 0 {
                break
            }
        }

        return returnCode
    }
}
