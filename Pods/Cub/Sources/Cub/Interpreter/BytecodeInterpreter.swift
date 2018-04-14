//
//  BytecodeInterpreter.swift
//  Cub
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

/// Bytecode Interpreter
public class BytecodeInterpreter {

	private let stackLimit = 65_536

	private let bytecode: [BytecodeExecutionInstruction]

	/// Stack
	private(set) public var stack: Stack<ValueType>

	/// Virtual map with id as key and program counter as value
	private var virtualMap = [Int: Int]()

	private var virtualEndMap = [Int: Int]()

	private var virtualInvokeStack: Stack<Int>

	private var virtualDepth = Counter(start: 0)

	/// Registers
	private(set) public var registers = [Int: ValueType]()

	private(set) var pcTrace = [Int]()
	
	var executionFinishedCallback: (() -> Void)?

	// MARK: - Init

	/// Initalize a BytecodeInterpreter with an array of BytecodeExecutionInstruction
	///
	/// - Parameter bytecode: Array of BytecodeExecutionInstruction
	public init(bytecode: [BytecodeExecutionInstruction]) throws {
		self.bytecode = bytecode

		stack = Stack<ValueType>(withLimit: stackLimit)
		registers = [Int: ValueType]()
		virtualInvokeStack = Stack<Int>(withLimit: stackLimit)

		try createVirtualMap()
	}

	private func createVirtualMap() throws {

		var pc = 0

		var funcStack = [Int]()

		for line in bytecode {

			if line.type == .virtualHeader {

				guard let arg = line.arguments.first, case let .index(id) = arg else {
					throw error(.unexpectedArgument)
				}

				// + 1 for first line in virtual
				// header should never be jumped to
				virtualMap[id] = pc + 1

				funcStack.append(id)
			}

			if line.type == .privateVirtualHeader {

				guard let arg = line.arguments.first, case let .index(id) = arg else {
					throw error(.unexpectedArgument)
				}

				// + 1 for first line in virtual
				// header should never be jumped to
				virtualMap[id] = pc + 1

				funcStack.append(id)
			}

			if line.type == .virtualEnd {

				guard let currentFunc = funcStack.popLast() else {
					throw error(.unexpectedArgument)
				}

				virtualEndMap[currentFunc] = pc

			}

			if line.type == .privateVirtualEnd {

				guard let currentFunc = funcStack.popLast() else {
					throw error(.unexpectedArgument)
				}

				virtualEndMap[currentFunc] = pc

			}

			pc += 1
		}

	}
	
	var externalFunctions = [Int: ([String], ExternalFunc)]()
	
	public func registerExternalFunction(id: Int, callback: ([String], ExternalFunc)) {

		externalFunctions[id] = callback
	}

	var pc = 0

	var isPaused = false
	
	func pause() {
		
		isPaused = true
		
	}
	
	func resume() {
		
		isPaused = false
		
	}
	
	/// Interpret the bytecode passed in the initializer
	///
	/// - Throws: InterpreterError
	public func interpret() throws {

		while true {
			
			if isPaused {
				Thread.sleep(forTimeInterval: 0.001)
				continue
			}

			pcTrace.append(pc)
			if let newPc = try executeInstruction(bytecode[pc], pc: pc) {
				pc = newPc
				
				if pc >= bytecode.count {
					executionFinishedCallback?()
					break
				}
				
			} else {
				continue
			}

		}

	}

	private func executeInstruction(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int? {

		let newPc: Int?

		// TODO: Cleaner (more generic) mapping possible?

		switch instruction.type {

			case .pushConst:
				newPc = try executePushConst(instruction, pc: pc)

			case .add:
				newPc = try executeAdd(pc: pc)

			case .sub:
				newPc = try executeSub(pc: pc)

			case .mul:
				newPc = try executeMul(pc: pc)

			case .div:
				newPc = try executeDiv(pc: pc)

			case .pow:
				newPc = try executePow(pc: pc)

			case .and:
				newPc = try executeAnd(pc: pc)

			case .or:
				newPc = try executeOr(pc: pc)

			case .not:
				newPc = try executeNot(pc: pc)

			case .eq:
				newPc = try executeEqual(pc: pc)

			case .neq:
				newPc = try executeNotEqual(pc: pc)

			case .cmple:
				newPc = try executeCmpLe(pc: pc)

			case .cmplt:
				newPc = try executeCmpLt(pc: pc)

			case .goto:
				newPc = try executeGoto(instruction)

			case .registerStore:
				newPc = try executeStore(instruction, pc: pc)

			case .registerUpdate:
				newPc = try executeRegisterUpdate(instruction, pc: pc)

			case .registerClear:
				newPc = try executeRegisterClear(instruction, pc: pc)

			case .registerLoad:
				newPc = try executeRegisterLoad(instruction, pc: pc)

			case .ifTrue:
				newPc = try executeIfTrue(instruction, pc: pc)

			case .ifFalse:
				newPc = try executeIfFalse(instruction, pc: pc)

			case .invokeVirtual:
				newPc = try executeInvokeVirtual(instruction, pc: pc)

			case .exitVirtual:
				newPc = try executeExitVirtual(instruction, pc: pc)

			case .pop:
				newPc = try executePop(instruction, pc: pc)

			case .skipPast:
				newPc = try executeSkipPast(instruction, pc: pc)

			case .structInit:
				newPc = try executeStructInit(instruction, pc: pc)

			case .structSet:
				newPc = try executeStructSet(instruction, pc: pc)

			case .structUpdate:
				newPc = try executeStructUpdate(instruction, pc: pc)

			case .structGet:
				newPc = try executeStructGet(instruction, pc: pc)

			case .virtualHeader:
				newPc = try executeVirtualHeader(instruction, pc: pc)

			case .privateVirtualHeader:
				newPc = try executePrivateVirtualHeader(instruction, pc: pc)

			case .virtualEnd:
				newPc = try executeVirtualEnd(instruction, pc: pc)

			case .privateVirtualEnd:
				newPc = try executePrivateVirtualEnd(instruction, pc: pc)

			case .arrayInit:
				newPc = try executeArrayInit(instruction, pc: pc)
			
			case .arraySet:
				newPc = try executeArraySet(instruction, pc: pc)
			
			case .arrayUpdate:
				newPc = try executeArrayUpdate(instruction, pc: pc)
			
			case .arrayGet:
				newPc = try executeArrayGet(instruction, pc: pc)
			
			case .sizeOf:
				newPc = try sizeOf(instruction, pc: pc)

		}

		return newPc
	}

	// MARK: - Execution

	private func executePushConst(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let arg = instruction.arguments.first, case let .value(f) = arg else {
			throw error(.unexpectedArgument)
		}

		try stack.push(f)

		return pc + 1
	}

	private func executeAdd(pc: Int) throws -> Int {

		let lhs = try stack.pop()
		let rhs = try stack.pop()

		switch (lhs, rhs) {
		case let (.number(n1), .number(n2)):
			try stack.push(.number(n1 + n2))
			
		case let (.number(n1), .string(n2)):
			try stack.push(.string("\(n1)\(n2)"))
			
		case let (.string(n1), .number(n2)):
			try stack.push(.string("\(n1)\(n2)"))
			
		case let (.string(n1), .string(n2)):
			try stack.push(.string("\(n1)\(n2)"))

		case let (.array(a1), .array(a2)):
			var array = a1
			array.append(contentsOf: a2)
			
			try stack.push(.array(array))
			
		case let (.array(a1), a2):
			var array = a1
			array.append(a2)
			
			try stack.push(.array(array))

		case let (a1, .array(a2)):
			var array = a2
			array.insert(a1, at: 0)
			
			try stack.push(.array(array))
			
		default:
			throw error(.unexpectedArgument)
		}

		return pc + 1
	}

	private func executeSub(pc: Int) throws -> Int {

		let rhs = try popNumber()
		let lhs = try popNumber()

		try stack.push(.number(lhs - rhs))

		return pc + 1
	}

	private func executeMul(pc: Int) throws -> Int {

		let lhs = try popNumber()
		let rhs = try popNumber()

		try stack.push(.number(lhs * rhs))

		return pc + 1
	}

	private func executeDiv(pc: Int) throws -> Int {

		let rhs = try popNumber()
		let lhs = try popNumber()

		try stack.push(.number(lhs / rhs))

		return pc + 1
	}

	private func executePow(pc: Int) throws -> Int {

		let rhs = try popNumber()
		let lhs = try popNumber()

		let p = pow(lhs, rhs)

		try stack.push(.number(p))

		return pc + 1
	}

	private func executeAnd(pc: Int) throws -> Int {

		let rhs = try popBool()
		let lhs = try popBool()

		let and: Bool = rhs && lhs

		try stack.push(.bool(and))

		return pc + 1
	}

	private func executeOr(pc: Int) throws -> Int {

		let rhs = try popBool()
		let lhs = try popBool()

		let and: Bool = rhs || lhs

		try stack.push(.bool(and))

		return pc + 1
	}

	private func executeNot(pc: Int) throws -> Int {

		let b = try popBool()

		let not: Bool = !b

		try stack.push(.bool(not))

		return pc + 1
	}

	private func executeEqual(pc: Int) throws -> Int {

		let rhs = try stack.pop()
		let lhs = try stack.pop()

		let eq: Bool = lhs == rhs

		try stack.push(.bool(eq))

		return pc + 1
	}

	private func executeNotEqual(pc: Int) throws -> Int {

		let rhs = try stack.pop()
		let lhs = try stack.pop()

		let neq: Bool = lhs != rhs

		try stack.push(.bool(neq))

		return pc + 1
	}

	private func executeCmpLe(pc: Int) throws -> Int {

		let rhs = try popNumber()
		let lhs = try popNumber()

		let cmp: Bool = lhs <= rhs

		try stack.push(.bool(cmp))

		return pc + 1
	}

	private func executeCmpLt(pc: Int) throws -> Int {

		let rhs = try popNumber()
		let lhs = try popNumber()

		let cmp: Bool = lhs < rhs

		try stack.push(.bool(cmp))

		return pc + 1
	}

	private func executeIfTrue(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let label = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}

		guard case let .index(i) = label else {
			throw error(.unexpectedArgument)
		}

		if try popBool() == true {

			if let newPc = try progamCounter(for: i) {
				return newPc
			} else {
				return bytecode.count
			}

		}

		return pc + 1

	}

	private func executeIfFalse(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let label = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}

		guard case let .index(i) = label else {
			throw error(.unexpectedArgument)
		}

		if try popBool() == false {

			if let newPc = try progamCounter(for: i) {
				return newPc
			} else {
				return bytecode.count
			}

		}

		return pc + 1

	}

	private func executeGoto(_ instruction: BytecodeExecutionInstruction) throws -> Int {

		guard let label = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}

		guard case let .index(i) = label else {
			throw error(.unexpectedArgument)
		}

		if let newPc = try progamCounter(for: i) {
			return newPc
		} else {
			return bytecode.count
		}

	}

	private func executeStore(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}

		guard case let .index(i) = reg else {
			throw error(.unexpectedArgument)
		}

		setRegValue(try stack.pop(), for: i)

		return pc + 1
	}

	private func executeRegisterUpdate(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}

		guard case let .index(i) = reg else {
			throw error(.unexpectedArgument)
		}

		try updateRegValue(try stack.pop(), for: i)

		return pc + 1
	}

	private func executeRegisterClear(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}

		guard case let .index(i) = reg else {
			throw error(.unexpectedArgument)
		}

		try removeRegValue(in: i)

		return pc + 1
	}

	private func executeRegisterLoad(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}

		guard case let .index(i) = reg else {
			throw error(.unexpectedArgument)
		}

		let regValue = try getRegValue(for: i)

		try stack.push(regValue)

		return pc + 1
	}

	private func executeInvokeVirtual(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int? {

		guard let id = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		guard case let .index(i) = id else {
			throw error(.unexpectedArgument)
		}

		if let (argumentNames, externalCallback) = externalFunctions[i] {
			
			var arguments = [String: ValueType]()
			
			for argName in argumentNames.reversed() {
				let arg = try stack.pop()
				arguments[argName] = arg
			}
			
			pause()
			
			externalCallback(arguments, { (result) in
				
				do {
					
					if let result = result {
						try self.stack.push(result)
					}
					
					self.pc += 1
					
					self.resume()

					return true
					
				} catch {
					
					return false
				}
			
			})

			return nil
		}
		
		guard let idPc = virtualMap[i] else {
			throw error(.unexpectedArgument)
		}

		// return to next pc after virtual returns
		try virtualInvokeStack.push(pc + 1)

		// Only increment depth if non-private virtual is called
		if bytecode[idPc - 1].type == .virtualHeader {
			virtualDepth.increment()
		}

		return idPc
	}

	private func executeExitVirtual(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let exitVirtualLabel = try? virtualInvokeStack.pop() else {
			throw error(.unexpectedArgument)
		}

		try virtualDepth.decrement()

		return exitVirtualLabel
	}

	private func executePop(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		_ = try stack.pop()

		return pc + 1
	}

	private func executeSkipPast(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let label = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}

		guard case let .index(i) = label else {
			throw error(.unexpectedArgument)
		}

		if let newPc = try progamCounter(for: i) {
			// FIXME: need to check if newPc >= bytecode.count?
			return newPc + 1
		} else {
			return bytecode.count
		}

	}

	private func executeStructInit(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		let newStruct = ValueType.struct([:])

		try stack.push(newStruct)

		return pc + 1
	}

	private func executeStructSet(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let arg = instruction.arguments.first, case let .index(key) = arg else {
			throw error(.unexpectedArgument)
		}

		guard case let ValueType.struct(v) = try stack.pop() else {
			throw error(.unexpectedArgument)
		}

		var newStruct = v

		newStruct[key] = try stack.pop()

		try stack.push(.struct(newStruct))

		return pc + 1
	}

	private func executeStructUpdate(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		let memberIds: [Int] = instruction.arguments.compactMap {
			if case let .index(i) = $0 {
				return i
			}
			return nil
		}

		guard case let ValueType.struct(v) = try stack.pop() else {
			throw error(.unexpectedArgument)
		}

		let updateValue = try stack.pop()

		let newStruct = try updatedDict(for: v, keyPath: memberIds, newValue: updateValue)

		try stack.push(.struct(newStruct))

		return pc + 1
	}

	private func executeStructGet(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let arg = instruction.arguments.first, case let .index(key) = arg else {
			throw error(.unexpectedArgument)
		}

		guard case let ValueType.struct(v) = try stack.pop() else {
			throw error(.unexpectedArgument)
		}

		guard let memberValue = v[key] else {
			throw error(.unexpectedArgument)
		}

		try stack.push(memberValue)

		return pc + 1
	}

	private func executeVirtualHeader(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let arg = instruction.arguments.first, case let .index(id) = arg else {
			throw error(.unexpectedArgument)
		}

		guard let virtualEndPc = virtualEndMap[id] else {
			throw error(.unexpectedArgument)
		}

		return virtualEndPc + 1

	}

	private func executePrivateVirtualHeader(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		guard let arg = instruction.arguments.first, case let .index(id) = arg else {
			throw error(.unexpectedArgument)
		}

		guard let virtualEndPc = virtualEndMap[id] else {
			throw error(.unexpectedArgument)
		}

		return virtualEndPc + 1

	}

	private func executeVirtualEnd(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		try virtualDepth.decrement()

		return try virtualInvokeStack.pop()
	}

	private func executePrivateVirtualEnd(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		return try virtualInvokeStack.pop()
	}
	
	private func executeArrayInit(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {
		
		guard let arg = instruction.arguments.first, case let .index(size) = arg else {
			throw error(.unexpectedArgument)
		}
		
		let newArray = ValueType.array([ValueType](repeating: .number(0), count: size))
		
		try stack.push(newArray)
		
		return pc + 1
	}
	
	private func executeArraySet(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {
		
		guard let arg = instruction.arguments.first, case let .index(i) = arg else {
			throw error(.unexpectedArgument)
		}
		
		let newValue = try stack.pop()
		
		guard case let ValueType.array(v) = try stack.pop() else {
			throw error(.unexpectedArgument)
		}
		
		var newArray = v
		
		guard i >= 0 && i < newArray.count else {
			throw error(.arrayOutOfBounds)
		}
		
		newArray[i] = newValue
		
		try stack.push(.array(newArray))
		
		return pc + 1
	}
	
	private func executeArrayUpdate(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {
		
		let v2 = try stack.pop()

		let index = try popNumber()
		let i = Int(index)
		
		let updateValue = try stack.pop()

		if case let ValueType.array(v) = v2 {
			
			var newArray = v
			
			guard i >= 0 && i < newArray.count else {
				throw error(.arrayOutOfBounds)
			}
			
			newArray[i] = updateValue
			
			try stack.push(.array(newArray))
			
		} else if case let ValueType.string(v) = v2 {

			guard case let .string(insertString) = updateValue else {
				throw error(.unexpectedArgument)
			}
			
			guard i >= 0 && i < v.count else {
				throw error(.arrayOutOfBounds)
			}
			
			let newString = String(v.prefix(i)) + insertString + String(v.dropFirst(i + 1))
			
			try stack.push(.string(newString))
			
		} else {
			
			throw error(.unexpectedArgument)

		}
		
		return pc + 1
	}
	
	private func executeArrayGet(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {
		
		guard case let ValueType.number(i) = try stack.pop() else {
			throw error(.unexpectedArgument)
		}
		
		let v2 = try stack.pop()
		if case let ValueType.array(v) = v2 {

			guard let memberValue = v[safe: Int(i)] else {
				throw error(.arrayOutOfBounds)
			}
			
			try stack.push(memberValue)
		
		} else if case let ValueType.string(v) = v2 {

			guard i >= 0 && Int(i) < v.count else {
				throw error(.arrayOutOfBounds)
			}
			
			let memberValue = v[v.index(v.startIndex, offsetBy: Int(i))]

			try stack.push(.string(String(memberValue)))
			
		} else {
			
			throw error(.unexpectedArgument)

		}
		
		return pc + 1
	}
	
	private func sizeOf(_ instruction: BytecodeExecutionInstruction, pc: Int) throws -> Int {

		let value = try stack.pop()
		
		let size: NumberType
		
		switch value {
		case .array(let array):
			size = NumberType(array.count)
			
		case .bool:
			size = 1
			
		case .number(let number):
			size = number
			
		case .string(let string):
			size = NumberType(string.count)
			
		case .struct(let stru):
			size = NumberType(stru.count)

		}
		
		try stack.push(.number(size))
		
		return pc + 1
	}

	// MARK: - Structs

	/// Get updated dictionary for given dictionary, updating with newValue at keyPath.
	/// Recursively traverses dictionary tree to update a value, then reconstructs the dictionary.
	/// E.g.
	/// dict = [0: [1: 4.0]]
	/// keyPath = [1, 0]
	/// newValue = 8.0
	/// -> [0: [1: 8.0]]
	private func updatedDict(for dict: [Int: ValueType], keyPath: [Int], newValue: ValueType, isReconstructing: Bool = false, trace: [[Int: ValueType]] = [], keyPathPassed: [Int] = []) throws -> [Int: ValueType] {

		var trace = trace
		var keyPathPassed = keyPathPassed

		if isReconstructing {

			if trace.isEmpty {
				return dict
			}

			guard let idPassed = keyPathPassed.popLast() else {
				throw error(.unexpectedArgument)
			}

			guard let lastTrace = trace.popLast() else {
				throw error(.unexpectedArgument)
			}

			var newDict = lastTrace
			newDict[idPassed] = .struct(dict)

			return try updatedDict(for: newDict, keyPath: keyPath, newValue: newValue, isReconstructing: true, trace: trace, keyPathPassed: keyPathPassed)
		}

		var dict = dict

		guard !keyPath.isEmpty else {
			throw error(.unexpectedArgument)
		}

		guard let id = keyPath.last else {
			throw error(.unexpectedArgument)
		}

		if keyPath.count == 1 {

			dict[id] = newValue

			return try updatedDict(for: dict, keyPath: keyPath, newValue: newValue, isReconstructing: true, trace: trace, keyPathPassed: keyPathPassed)

		} else {

			trace.append(dict)
			keyPathPassed.append(id)

			var keyPath = keyPath

			guard let v = dict[id] else {
				throw error(.unexpectedArgument)
			}

			guard case let ValueType.struct(dictToUpdate) = v else {
				throw error(.unexpectedArgument)
			}

			keyPath.removeLast()

			return try updatedDict(for: dictToUpdate, keyPath: keyPath, newValue: newValue, trace: trace, keyPathPassed: keyPathPassed)
		}

	}

	// MARK: - Registers

	private func removeRegValue(in reg: Int) throws {

		guard let key = privateReg(for: reg) else {
			return
//			throw error(.unexpectedArgument)
		}

		regMap[reg]?.removeLast()
		
		if regMap[reg]?.isEmpty == true {
			regMap.removeValue(forKey: reg)
		}
		
		registers.removeValue(forKey: key)

		// TODO: throw error?
//		guard let _ = registers.removeValue(forKey: key) else {
//			throw error(.unexpectedArgument)
//		}
	}

	public func getRegValue(for reg: Int) throws -> ValueType {

		guard let key = privateReg(for: reg) else {
			throw error(.invalidRegister)
		}

		guard let regValue = registers[key] else {
			throw error(.invalidRegister)
		}

		return regValue
	}

	private func setRegValue(_ value: ValueType, for reg: Int) {

		let privateKey = virtualDepth.value * regPrivateKeyPrefixSize + reg

		// FIXME: make faster?
		if regMap[reg] != nil {
			if regMap[reg]?.contains(virtualDepth.value) != true {
				regMap[reg]?.append(virtualDepth.value)
			}
		} else {
			regMap[reg] = [virtualDepth.value]
		}
		
//		regMap[reg, default: []].append(virtualDepth.value)

		registers[privateKey] = value

	}

	private func updateRegValue(_ value: ValueType, for reg: Int) throws {

		guard let privateKey = privateReg(for: reg) else {
			throw error(.invalidRegister)
		}

		registers[privateKey] = value

	}

	/// Maps compiled regs to runtime reg names.
	/// This allows for correct recursion, since multiple variables
	/// with the same name might point to different registers.
	private var regMap = [Int: [Int]]()

	// Also the max number of private keys for each reg
	private let regPrivateKeyPrefixSize = 10_000

	private func privateReg(for reg: Int) -> Int? {

		guard let id = regMap[reg]?.last else {
			return nil
		}

		guard reg < regPrivateKeyPrefixSize else {
			return nil
		}

		return id * regPrivateKeyPrefixSize + reg
	}

	public func regName(for privateReg: Int) -> Int? {

		for (k, v) in regMap {

			guard k < regPrivateKeyPrefixSize else {
				continue
			}

			for reg in v {

				let privateKey = reg * regPrivateKeyPrefixSize + k

				if privateKey == privateReg {
					return k
				}

			}

		}

		return nil
	}

	// MARK: -

	// TODO: max cache size?
	private var labelProgramCountersCache = [Int: Int]()

	private func progamCounter(for label: Int) throws -> Int? {

		if let pc = labelProgramCountersCache[label] {
			return pc
		}

		let foundLabel = bytecode.index(where: { (b) -> Bool in
			return b.label == label
		})

		if foundLabel == nil {

			if let exitVirtualLabel = try? virtualInvokeStack.pop() {

				try virtualDepth.decrement()

				return exitVirtualLabel
			}

		}

		labelProgramCountersCache[label] = foundLabel

		return foundLabel
	}

	// MARK: - Stack

	private func popNumber() throws -> NumberType {

		let last = try stack.pop()

		guard case let ValueType.number(number) = last else {
			throw error(.unexpectedArgument)
		}

		return number
	}

	private func popBool() throws -> Bool {

		let last = try stack.pop()

		guard case let ValueType.bool(bool) = last else {
			throw error(.unexpectedArgument)
		}

		return bool
	}

	// MARK: -

	private func error(_ type: InterpreterErrorType) -> InterpreterError {

		return InterpreterError(type: type, range: bytecode[safe: pc]?.range)
	}

}
