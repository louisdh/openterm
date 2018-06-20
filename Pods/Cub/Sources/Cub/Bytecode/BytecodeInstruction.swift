//
//  BytecodeInstruction.swift
//  Cub
//
//  Created by Louis D'hauwe on 08/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public typealias BytecodeBody = [BytecodeInstruction]

/// Scorpion Bytecode Instruction
public class BytecodeInstruction {

	let label: Int
	let type: BytecodeInstructionType
	let arguments: [InstructionArgumentType]
	let comment: String?
	
	/// The range of the instruction in the original source code
	let range: Range<Int>?

	/// Use for decoding compiled instructions.
	/// Does not support comments.
	public init(instructionString: String) throws {

		let substrings = instructionString.components(separatedBy: " ")

		guard let label = substrings[safe: 0] else {
			throw BytecodeInstruction.error(.invalidDecoding)
		}

		guard let labelInt = Int(label) else {
			throw BytecodeInstruction.error(.invalidDecoding)
		}

		self.label = labelInt

		guard let opCodeString = substrings[safe: 1], let opCode = UInt8(opCodeString) else {
			throw BytecodeInstruction.error(.invalidDecoding)
		}

		guard let type = BytecodeInstructionType(rawValue: opCode) else {
			throw BytecodeInstruction.error(.invalidDecoding)
		}

		self.type = type

		if let args = substrings[safe: 2]?.components(separatedBy: ",") {

			var argsParsed = [InstructionArgumentType]()

			for arg in args {

				var arg = arg

				if arg.hasPrefix("i") {

					arg = arg.replacingOccurrences(of: "i", with: "")

					guard let i = Int(arg) else {
						throw BytecodeInstruction.error(.invalidDecoding)
					}

					argsParsed.append(InstructionArgumentType.index(i))

				} else if arg.hasPrefix("v") {

					arg = arg.replacingOccurrences(of: "v", with: "")

					// TODO: support decoding
//					guard let v = NumberType(arg) else {
//						throw BytecodeInstruction.error(.invalidDecoding)
//					}
//
//					argsParsed.append(InstructionArgumentType.value(v))

				}

			}

			self.arguments = argsParsed

		} else {
			self.arguments = []
		}

		self.comment = nil
		self.range = nil

	}

	init(label: Int, type: BytecodeInstructionType, arguments: [InstructionArgumentType] = [], comment: String? = nil, range: Range<Int>?) {

		self.label = label
		self.type = type
		self.arguments = arguments
		self.comment = comment
		self.range = range

	}

	/// Encoding string to use for saving compiled instruction (e.g. to disk).
	public var encoded: String {
		var args = ""

		var i = 0
		for a in arguments {
			args += a.encoded
			i += 1

			if i != arguments.count {
				args += ","
			}
		}

		var descr = "\(label) \(type.opCode)"

		if !args.isEmpty {
			descr += " \(args)"
		}

		return descr
	}

	/// Debug description
	public var description: String {
		var args = ""

		var i = 0
		for a in arguments {
			args += a.encoded
			i += 1

			if i != arguments.count {
				args += ","
			}
		}

		var descr = "\(label): \(type.description)"

		if !args.isEmpty {
			descr += " \(args)"
		}

		if let comment = comment {
			descr += "; \(comment)".byAppendingLeading(" ", max(1, 30 - descr.count))
		}

		return descr
	}

	// MARK: -

	private static func error(_ type: BytecodeInstructionError) -> Error {
		return type
	}

}

extension String {

	func byAppendingLeading(_ string: String, _ times: Int) -> String {
		return times > 0 ? String(repeating: string, count: times) + self : self
	}

}
