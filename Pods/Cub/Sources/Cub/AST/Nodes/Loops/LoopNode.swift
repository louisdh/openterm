//
//  LoopNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 09/12/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

protocol LoopNode: ASTNode {

	func compileLoop(with ctx: BytecodeCompiler, scopeStart: Int) throws -> BytecodeBody

}

extension LoopNode {

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		ctx.enterNewScope()

		let skipExitInstrLabel = ctx.nextIndexLabel()

		let exitLoopInstrLabel = ctx.nextIndexLabel()

		ctx.pushLoopHeader(exitLoopInstrLabel)

		let loopScopeStart = ctx.peekNextIndexLabel()

		let compiledLoop = try compileLoop(with: ctx, scopeStart: loopScopeStart)

		let loopEndLabel = ctx.peekNextIndexLabel()

		let skipExitInstruction = BytecodeInstruction(label: skipExitInstrLabel, type: .goto, arguments: [.index(loopScopeStart)], comment: "skip exit instruction", range: range)
		bytecode.append(skipExitInstruction)

		let exitLoopInstruction = BytecodeInstruction(label: exitLoopInstrLabel, type: .goto, arguments: [.index(loopEndLabel)], comment: "exit loop", range: range)
		bytecode.append(exitLoopInstruction)

		bytecode.append(contentsOf: compiledLoop)

		ctx.popLoopHeader()

		try ctx.leaveCurrentScope()

		return bytecode
	}

}
