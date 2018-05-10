//
//  BytecodeCompiler.swift
//  Cub
//
//  Created by Louis D'hauwe on 07/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public enum CompilerOptimizationLevel: Int {
	case none = 0
}

// TODO: implement
public struct BytecodeCompilerOptions: OptionSet {
    public let rawValue: Int

	public init(rawValue: BytecodeCompilerOptions.RawValue) {
		self.rawValue = rawValue
	}
	
	static public let generateBytecodeComments = BytecodeCompilerOptions(rawValue: 1 << 0)
	static public let removeUnusedFunctions = BytecodeCompilerOptions(rawValue: 1 << 1)
	static public let removeUnusedVars = BytecodeCompilerOptions(rawValue: 1 << 2)
	static public let removeEmptyCleanups = BytecodeCompilerOptions(rawValue: 1 << 3)

	static public let debug: BytecodeCompilerOptions = []
	
	static public let all: BytecodeCompilerOptions = [.generateBytecodeComments,
	                                                  .removeUnusedFunctions,
	                                                  .removeUnusedVars,
	                                                  .removeEmptyCleanups]
}

/// Scorpion Bytecode Compiler
public class BytecodeCompiler {

	// MARK: - Private

	private var index: UInt

	private var loopHeaderStack: [Int]
	private var loopContinueStack: [Int]

	private var functionExitStack: [Int]

	private var structMemberIndex: Int

	private var structMemberMap: [String: Int]

	private let scopeTreeRoot: ScopeNode

	private var currentScopeNode: ScopeNode

	let options: BytecodeCompilerOptions
	let optimizationLevel: CompilerOptimizationLevel
	
	// MARK: -

	public init(options: BytecodeCompilerOptions = .all, optimizationLevel: CompilerOptimizationLevel = .none) {

		self.options = options
		self.optimizationLevel = optimizationLevel
		
		index = 0

		loopHeaderStack = [Int]()
		loopContinueStack = [Int]()
		functionExitStack = [Int]()

		scopeTreeRoot = ScopeNode(childNodes: [])
		currentScopeNode = scopeTreeRoot

		structMemberIndex = 0
		structMemberMap = [String: Int]()

	}

	// MARK: - Public

	public func compile(_ ast: [ASTNode]) throws -> BytecodeBody {

		try compileFunctionPrototypes(for: ast)
		try mapStructMembers(for: ast)

		var bytecode = BytecodeBody()

		for node in ast {

			let compiled = try node.compile(with: self, in: nil)
			bytecode.append(contentsOf: compiled)

		}

		let cleanupGlobal = cleanupRegisterInstructions()
		bytecode.append(contentsOf: cleanupGlobal)

		return bytecode
	}

	// MARK: -

	private func mapStructMembers(for ast: [ASTNode]) throws {

		for node in ast {

			if let structNode = node as? StructNode {

				for memberName in structNode.prototype.members {

					if !structMemberMap.keys.contains(memberName) {
						structMemberIndex += 1
						structMemberMap[memberName] = structMemberIndex
					}

				}

			}

		}

	}

	private func compileFunctionPrototypes(for ast: [ASTNode]) throws {

		for node in ast {

			if let funcNode = node as? FunctionNode {

				_ = getFunctionId(for: funcNode)

				try compileFunctionPrototypes(for: funcNode.childNodes)

			} else {

				try compileFunctionPrototypes(for: node.childNodes)

			}

		}

	}

	// MARK: - Labels

	func nextIndexLabel() -> Int {
		index += 1
		return Int(index)
	}

	func peekNextIndexLabel() -> Int {
		return Int(index + 1)
	}

	public func currentLabelIndex() -> UInt {
		return index
	}

	/// Explicitly set the label index.
	/// Meant for code injection.
	public func setLabelIndex(to newIndex: UInt) {
		index = newIndex
	}

	// TODO: make stack operations throw?

	// MARK: - Loop header

	func pushLoopHeader(_ label: Int) {
		loopHeaderStack.append(label)
	}

	@discardableResult
	func popLoopHeader() -> Int? {
		return loopHeaderStack.popLast()
	}

	func peekLoopHeader() -> Int? {
		return loopHeaderStack.last
	}

	// MARK: - Loop continue

	func pushLoopContinue(_ label: Int) {
		loopContinueStack.append(label)
	}

	func popLoopContinue() -> Int? {
		return loopContinueStack.popLast()
	}

	func peekLoopContinue() -> Int? {
		return loopContinueStack.last
	}

	// MARK: - Return stack

	func pushFunctionExit(_ label: Int) {
		functionExitStack.append(label)
	}

	@discardableResult
	func popFunctionExit() -> Int? {
		return functionExitStack.popLast()
	}

	func peekFunctionExit() -> Int? {
		return functionExitStack.last
	}

	// MARK: - Scope tree

	func enterNewScope() {

		let newScopeNode = ScopeNode(parentNode: currentScopeNode, childNodes: [])
		currentScopeNode.childNodes.append(newScopeNode)
		currentScopeNode = newScopeNode

	}

	func addCleanupRegistersToCurrentScope() {

		let regsToClean = registersToClean(for: currentScopeNode)
		currentScopeNode.registersToClean.append(contentsOf: regsToClean)

	}

	func addCleanupRegistersToParentScope() {

		currentScopeNode.addRegistersToCleanToParent()

	}

	func leaveCurrentScope() throws {

		guard let parentNode = currentScopeNode.parentNode else {
			// End of program reached (top scope left)
			return
		}

		guard let i = parentNode.childNodes.index(where: {
			$0 === currentScopeNode
		}) else {
			throw error(.unbalancedScope)
		}

		addCleanupRegistersToCurrentScope()
		addCleanupRegistersToParentScope()

		parentNode.childNodes.remove(at: i)
		currentScopeNode = parentNode

	}

	public func getCompiledRegister(for varName: String) -> Int? {

		let deepRegMap = currentScopeNode.deepRegisterMap()

		let decompiledVarName = deepRegMap.first(where: { (keyValue: (key: String, value: Int)) -> Bool in
			return keyValue.key == varName
		})?.value

		return decompiledVarName
	}

	func getDecompiledVarName(for register: Int) -> String? {

		let deepRegMap = currentScopeNode.deepRegisterMap()

		let decompiledVarName = deepRegMap.first(where: { (keyValue: (key: String, value: Int)) -> Bool in
			return keyValue.value == register
		})?.key

		return decompiledVarName
	}

	func cleanupRegisterInstructions() -> BytecodeBody {
		return cleanupRegisterInstructions(for: currentScopeNode)
	}

	private func registersToClean(for scopeNode: ScopeNode) -> [(Int, String?)] {

		var registersToCleanup = scopeNode.registerMap.map { (kv) -> (Int, String?) in
			return (kv.1, kv.0)
		}

		registersToCleanup.append(contentsOf: scopeNode.internalRegisters.map {
			return ($0, nil)
		})

		return registersToCleanup
	}

	private func cleanupRegisterInstructions(for scopeNode: ScopeNode) -> BytecodeBody {

		var instructions = BytecodeBody()

		for (reg, decompiledVarName) in scopeNode.registersToClean {

			let label = nextIndexLabel()

			let comment: String?

			if options.contains(.generateBytecodeComments) {
				
				if let decompiledVarName = decompiledVarName {
					comment = "cleanup \(decompiledVarName)"
				} else {
					comment = "cleanup"
				}
				
			} else {
				
				comment = nil
			}
			
			let instr = BytecodeInstruction(label: label, type: .registerClear, arguments: [.index(reg)], comment: comment, range: nil)
			instructions.append(instr)

		}

		for (id, key) in scopeNode.registersToClean {
			if let key = key {
				if scopeNode.registerMap[key] == id {
					scopeNode.registerMap.removeValue(forKey: key)
				}
			}
		}

		scopeNode.internalRegisters.removeAll()
		scopeNode.registersToClean.removeAll()

		return instructions

	}

	// MARK: - Structs

	public func getStructMemberId(for memberName: String) -> Int? {
		return structMemberMap[memberName]
	}

	public func getStructMemberName(for id: Int) -> String? {
		return structMemberMap.first(where: { (_, v) -> Bool in
			return v == id
		})?.0
	}

	// MARK: - Registers

	private var registerCount = 0

	/// Get register for var name
	///
	/// - Parameter varName: var name
	/// - Returns: Register and boolean (true = register is new, false = reused)
	func getRegister(for varName: String) -> (Int, Bool) {

		if let existingReg = currentScopeNode.deepRegisterMap()[varName] {
			return (existingReg, false)
		}

		let newReg = getNewRegister()
		currentScopeNode.registerMap[varName] = newReg

		return (newReg, true)
	}

	func getNewInternalRegisterAndStoreInScope() -> Int {

		let newReg = getNewRegister()
		currentScopeNode.internalRegisters.append(newReg)

		return newReg

	}

	private func getNewRegister() -> Int {
		registerCount += 1
		return registerCount
	}

	// MARK: - Function ids

	// TODO: rename to virtual?

	private var functionCount = 0

	func getStructId(for structNode: StructNode) -> Int {

		let name = structNode.prototype.name

		if let functionMapped = currentScopeNode.deepFunctionMap()[name] {
			return functionMapped.id
		}

		let newReg = getNewFunctionId()
		let exitReg = getNewFunctionId()

		currentScopeNode.functionMap[name] = FunctionMapped(id: newReg, exitId: exitReg, arguments: structNode.prototype.members, returns: true)

		return newReg
	}

	/// Will make new id if needed
	func getFunctionId(for functionNode: FunctionNode) -> Int {

		let name = functionNode.prototype.name

		if let functionMapped = currentScopeNode.deepFunctionMap()[name] {
			return functionMapped.id
		}

		let newReg = getNewFunctionId()
		let exitReg = getNewFunctionId()

		currentScopeNode.functionMap[name] = FunctionMapped(id: newReg, exitId: exitReg, arguments: functionNode.prototype.argumentNames,  returns: functionNode.prototype.returns)

		return newReg
	}

	func getMappedFunction(named name: String) -> FunctionMapped? {
		return currentScopeNode.deepFunctionMap()[name]
	}

	func getExitScopeFunctionId(for functionNode: FunctionNode) throws -> Int {

		let name = functionNode.prototype.name

		guard let functionMapped = currentScopeNode.deepFunctionMap()[name] else {
			throw error(.functionNotFound(name))
		}

		return functionMapped.exitId

	}

	/// Expects function id to exist
	func getCallFunctionId(for functionName: String) throws -> Int {

		if let functionMapped = currentScopeNode.deepFunctionMap()[functionName] {
			return functionMapped.id
		}

		throw error(.functionNotFound(functionName))
	}

	func doesFunctionReturn(for functionName: String) throws -> Bool {

		if let functionMapped = currentScopeNode.deepFunctionMap()[functionName] {
			return functionMapped.returns
		}

		throw error(.functionNotFound(functionName))

	}

	private func getNewFunctionId() -> Int {
		functionCount += 1
		return functionCount
	}

	// MARK: -

	private func error(_ type: CompileErrorType) -> CompileError {
		return CompileError(type: type, range: nil)
	}

}
