//
//  CubRunner.swift
//  Cub
//
//  Created by Louis D'hauwe on 15/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation
import CoreFoundation

public typealias ExternalFunc = ([String: ValueType], _ callback: @escaping (ValueType?) -> Bool) -> Void

public typealias ExternalVarCallback = () -> ValueType

precedencegroup Pipe {
	associativity: left
	higherThan: AdditionPrecedence
}

infix operator |> : Pipe

internal func |><A, B, C>(lhs: @escaping (A) -> B,
                       rhs: @escaping (B) -> C) -> (A) -> C {
	return { rhs(lhs($0)) }
}

internal func |><A, B, C>(lhs: @escaping (A) throws -> B,
                 rhs: @escaping (B) throws -> C) -> (A) throws -> C {
	return { try rhs(lhs($0)) }
}

struct ExternalFunctionDefinition {
	
	let name: String
	let documentation: String?
	let argumentNames: [String]
	let callback: ExternalFunc
	let returns: Bool
	
}

struct ExternalVariableDefinition {
	
	let name: String
	let callback: ExternalVarCallback
	let documentation: String?

	func source(runner: Runner) -> String {
		
		let value = callback()
		
		return "\(name) = \(runner.source(for: value))"
	}
	
}

extension Runner {
	
	func source(for value: ValueType) -> String {
		
		switch value {
		case .array(let array):
			return "[\(array.map({ source(for: $0) }).joined(separator: ", "))]"
			
		case .bool(let bool):
			return "\(bool)"
			
		case .number(let number):
			return "\(number)"

		case .string(let string):
			return "\"\(string)\""

		case .struct:
			fatalError("Struct code gen is currently unavailable")
			
		case .nil:
			return "nil"
			
		}
		
	}

}

/// Runs through full pipeline, from lexer to interpreter
public class Runner {

	private let logDebug: Bool
	private let logTime: Bool

	private var source: String?

	public var delegate: RunnerDelegate?

	public let compiler: BytecodeCompiler
	
	// MARK: -

	public init(logDebug: Bool = false, logTime: Bool = false) {
		self.logDebug = logDebug
		self.logTime = logTime
		compiler = BytecodeCompiler()
	}
	
	var externalFunctions = [Int: ExternalFunctionDefinition]()
	
	public func registerExternalFunction(documentation: String?, name: String, argumentNames: [String], returns: Bool, callback: @escaping ExternalFunc) {

		let prototype = FunctionPrototypeNode(name: name, argumentNames: argumentNames, returns: returns, range: nil)
		let node = FunctionNode(prototype: prototype, body: BodyNode(nodes: [], range: nil), range: nil, documentation: nil)
		let id = compiler.getFunctionId(for: node)
		
		externalFunctions[id] = ExternalFunctionDefinition(name: name, documentation: documentation, argumentNames: argumentNames, callback: callback, returns: returns)
	}
	
	var externalVariables = [String: ExternalVariableDefinition]()
	
	public func registerExternalVariable(documentation: String?, name: String, callback: @escaping ExternalVarCallback) {
		
		let def = ExternalVariableDefinition(name: name, callback: callback, documentation: documentation)
		
		externalVariables[name] = def
	}
	
	public func runSource(at path: String, get varName: String, useStdLib: Bool = true) throws -> ValueType {

		let source = try String(contentsOfFile: path, encoding: .utf8)

		return try run(source, get: varName, useStdLib: useStdLib)
	}

	public func run(_ source: String, get varName: String, useStdLib: Bool = true) throws -> ValueType {

		let bytecode: BytecodeBody

		let externalVarsSource = externalVariables.values.map({ $0.source(runner: self) }).joined(separator: "\n")

		let externalVarsBytecode = try compileCubSourceCode(externalVarsSource)
		
		if useStdLib {

			let stdLib = StdLib()
			
			stdLib.registerExternalFunctions(self)
			
			let stdLibCode = try stdLib.stdLibCode()

			guard let compiledStdLib = try? compileCubSourceCode(stdLibCode) else {
				throw RunnerError.stdlibFailed
			}

			let compiledSource = try compileCubSourceCode(source)

			bytecode = compiledStdLib + externalVarsBytecode + compiledSource

		} else {

			let compiledSource = try compileCubSourceCode(source)

			bytecode = externalVarsBytecode + compiledSource

		}

		let executionBytecode = bytecode.map { $0.executionInstruction }

		let interpreter = try BytecodeInterpreter(bytecode: executionBytecode)
		
		for (id, definition) in externalFunctions {
			interpreter.registerExternalFunction(id: id, callback: (definition.argumentNames, definition.callback))
		}
		
		try interpreter.interpret()

		guard let reg = compiler.getCompiledRegister(for: varName) else {
			throw RunnerError.registerNotFound
		}

		do {
			return try interpreter.getRegValue(for: reg)
		} catch {
			throw RunnerError.registerNotFound
		}

	}

	public func runSource(at path: String) throws {

		let source = try String(contentsOfFile: path, encoding: .utf8)

		try run(source)
	}

	public func run(_ source: String) throws {

		let startTime = CFAbsoluteTimeGetCurrent()

		let stdLib = StdLib()
		
		stdLib.registerExternalFunctions(self)
		
		let stdLibCode = try stdLib.stdLibCode()
		
		guard let compiledStdLib = try? compileCubSourceCode(stdLibCode) else {
			throw RunnerError.stdlibFailed
		}

		self.source = source

		if logDebug {
			logSourceCode(source)
		}

		let externalVarsSource = externalVariables.values.map({ $0.source(runner: self) }).joined(separator: "\n")
		
		let externalVarsBytecode = try compileCubSourceCode(externalVarsSource)
		
		let compiledSource = try compileCubSourceCode(source)
		
		let fullBytecode = compiledStdLib + externalVarsBytecode + compiledSource

		let interpretStartTime = CFAbsoluteTimeGetCurrent()

		try interpret(fullBytecode)

		if logTime {

			let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

			let interpretTimeElapsed = CFAbsoluteTimeGetCurrent() - interpretStartTime

			log("\nTotal execution time: \(timeElapsed)s")

			log("\nInterpret execution time: \(interpretTimeElapsed)s")

			log("Instructions executed: \(interpreter?.pcTrace.count ?? 0)")

		}

	}

	public func runWithoutStdlib(_ source: String) throws {

		self.source = source

		let startTime = CFAbsoluteTimeGetCurrent()

		if logDebug {
			logSourceCode(source)
		}

		let compiledSource = try compileCubSourceCode(source)

		let fullBytecode = compiledSource

		let interpretStartTime = CFAbsoluteTimeGetCurrent()

		try interpret(fullBytecode)

		if logDebug {

			let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
			log("\nTotal execution time: \(timeElapsed)s")

			let interpretTimeElapsed = CFAbsoluteTimeGetCurrent() - interpretStartTime
			log("\nInterpret execution time: \(interpretTimeElapsed)s")

			log("Instructions executed: \(interpreter?.pcTrace.count ?? 0)")

		}

	}

	// MARK: -
	
	func parseAST(_ source: String) throws -> [ASTNode] {
		return try (runLexer |> parseTokens)(source)
	}
	
	func compileCubSourceCode(_ source: String) throws -> BytecodeBody {

		let ast = try parseAST(source)

		let bytecode = try compileToBytecode(ast: ast)
		
		return bytecode
	}

	private func runCubSourceCode(_ source: String) throws {

		let bytecode = try compileCubSourceCode(source)

		try interpret(bytecode)

	}

	private func runLexer(withSource source: String) -> [Token] {

		if logDebug {
			logTitle("Start lexer")
		}

		let lexer = Lexer(input: source)
		let tokens = lexer.tokenize()

		if logDebug {

			log("Number of tokens: \(tokens.count)")

			for t in tokens {
				log(t)
			}

		}

		return tokens

	}
	
	// MARK: - Throwing convenience
	
	public func compileToBytecode(_ source: String) throws -> BytecodeBody {
		return try (lexer |> parse |> compile)(source)
	}
	
	func lexer(_ source: String) throws -> [Token] {
		
		let lexer = Lexer(input: source)
		let tokens = lexer.tokenize()
		
		return tokens
	}
	
	func parse(_ tokens: [Token]) throws -> [ASTNode] {
		let parser = Parser(tokens: tokens)
		return try parser.parse()
	}
	
	func compile(_ ast: [ASTNode]) throws -> BytecodeBody {
		return try compiler.compile(ast)
	}
	
	// MARK: -

	private func parseTokens(_ tokens: [Token]) throws -> [ASTNode] {

		if logDebug {
			logTitle("Start parser")
		}

		let parser = Parser(tokens: tokens)

		let ast = try parser.parse()
		
		if logDebug {
			
			log("Parsed AST:")
			
			for a in ast {
				log(a.description)
			}
			
		}
		
		return ast
	}

	private func compileToBytecode(ast: [ASTNode]) throws -> BytecodeBody {

		if logDebug {
			logTitle("Start bytecode compiler")
		}

		let bytecode = try compiler.compile(ast)
		
		if logDebug {
			logBytecode(bytecode)
		}
		
		return bytecode
	}

	var interpreter: BytecodeInterpreter?

	private func interpret(_ bytecode: BytecodeBody) throws {

		if logDebug {
			logTitle("Start bytecode interpreter")
		}

		let executionBytecode = bytecode.map { $0.executionInstruction }
		
		let interpreter = try BytecodeInterpreter(bytecode: executionBytecode)
		
		for (id, definition) in externalFunctions {
			interpreter.registerExternalFunction(id: id, callback: (definition.argumentNames, definition.callback))
		}
		
		self.interpreter = interpreter
		
		try interpreter.interpret()
		
		if logDebug {
			logInterpreter(interpreter)
		}

	}
	
	func printTrace(_ bytecode: BytecodeBody) {
		
		if let interpreter = interpreter {
			for pc in interpreter.pcTrace {
				log(bytecode[pc].description)
			}
		}
		
	}

	// MARK: -
	// MARK: Logging

	func logInterpreter(_ interpreter: BytecodeInterpreter) {

		log("Stack at end of execution:\n\(interpreter.stack)\n")

		log("Registers at end of execution:")

		logRegisters(interpreter)

	}

	private func logRegisters(_ interpreter: BytecodeInterpreter) {

		for (key, value) in interpreter.registers {

			if let compiledKey = interpreter.regName(for: key),
				let varName = compiler.getDecompiledVarName(for: compiledKey) {

				log("\(varName) (\(key)) = \(value.description(with: compiler))")

			} else {

				log("\(key) = \(value)")

			}

		}

	}

	private func logSourceCode(_ source: String) {

		logTitle("Source code")

		for s in source.components(separatedBy: "\n") {
			log(s)
		}

	}

	private func logTitle(_ title: String) {

		log("================================")
		log(title)
		log("================================\n")

	}

	private func logBytecode(_ bytecode: BytecodeBody) {

		let bytecodeDescriptor = BytecodeDescriptor(bytecode: bytecode)
		
		log(bytecodeDescriptor.humanReadableDescription())

	}

	private func log(_ message: String) {
		delegate?.log(message)
	}

	private func log(_ error: Error) {

		guard let source = source else {
			delegate?.log(error)
			return
		}

		if let parseError = error as? ParseError {

			let errorDescription = parseError.description(inSource: source)
			delegate?.log(errorDescription)

		} else {

			delegate?.log(error)

		}

	}

	private func log(_ token: Token) {
		delegate?.log(token)
	}

}
