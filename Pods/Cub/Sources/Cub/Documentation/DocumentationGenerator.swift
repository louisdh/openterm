//
//  DocumentationGenerator.swift
//  Cub
//
//  Created by Louis D'hauwe on 19/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public class DocumentationGenerator {
	
	public init() {
		
	}
	
	public func items(runner: Runner) -> [DocumentationItem] {
		
		var items = [DocumentationItem]()
		
		let stdLib = StdLib()
		if let stbLibSource = try? stdLib.stdLibCode() {
			
			if let sourceItems = try? self.items(for: stbLibSource) {
				items.append(contentsOf: sourceItems)
			}
			
		}
		
		stdLib.registerExternalFunctions(runner)
		
		for externalFuncDef in runner.externalFunctions.values {
			
			let item = parsedDocumentation(for: externalFuncDef)
			items.append(item)

		}
		
		return items
	}
	
	func items(for source: String) throws -> [DocumentationItem] {
		
		var items = [DocumentationItem]()

		let tokens = Lexer(input: source).tokenize()

		let parser = Parser(tokens: tokens)
		let ast = try parser.parse()
		
		for node in ast {
			
			if let functionNode = node as? FunctionNode {
				
				let functionItem = parsedDocumentation(for: functionNode)
				
				items.append(functionItem)
			}
			
			if let assignmentNode = node as? AssignmentNode {

				if let item = parsedDocumentation(for: assignmentNode) {
					items.append(item)
				}
				
			}
			
			if let structNode = node as? StructNode {
				
				let structItem = parsedDocumentation(for: structNode)
				
				items.append(structItem)
			}
			
		}
		
		return items
	}
	
	private func parsedDocumentation(for assignmentNode: AssignmentNode) -> DocumentationItem? {
		
		guard let varNode = assignmentNode.variable as? VariableNode else {
			return nil
		}
		
		let definition = varNode.name
		let title = varNode.name
		
		let variableDocumentation: VariableDocumentation?
		
		let rawDocumentation = assignmentNode.documentation
		if let rawDocumentation = rawDocumentation {
			
			variableDocumentation = parsedVariableDocumentation(rawDocumentation: rawDocumentation)
			
		} else {
			
			variableDocumentation = nil
		}
		
		let varItem = DocumentationItem(definition: definition, rawDocumentation: rawDocumentation, type: .variable, functionDocumentation: nil, variableDocumentation: variableDocumentation, structDocumentation: nil, title: title)
		
		return varItem
	}

	private func parsedDocumentation(for externalFunctionDefinition: ExternalFunctionDefinition) -> DocumentationItem {

		let args = externalFunctionDefinition.argumentNames.joined(separator: ", ")
		var definition = "func \(externalFunctionDefinition.name)(\(args))"
		var title = "\(externalFunctionDefinition.name)(\(args))"

		if externalFunctionDefinition.returns {
			definition += " returns"
			title += " returns"
		}
		
		let functionDocumentation: FunctionDocumentation?
		
		let rawDocumentation = externalFunctionDefinition.documentation
		if let rawDocumentation = rawDocumentation {
			
			functionDocumentation = parsedFunctionDocumentation(rawDocumentation: rawDocumentation, arguments: externalFunctionDefinition.argumentNames, returns: externalFunctionDefinition.returns)
			
		} else {
			
			functionDocumentation = nil
		}
		
		let functionItem = DocumentationItem(definition: definition, rawDocumentation: rawDocumentation, type: .function, functionDocumentation: functionDocumentation, variableDocumentation: nil, structDocumentation: nil, title: title)
		
		return functionItem
		
	}
	
	private func parsedDocumentation(for structNode: StructNode) -> DocumentationItem {
		
		let args = structNode.prototype.members.joined(separator: ", ")
		let definition = "struct \(structNode.prototype.name)(\(args))"
		let title = "\(structNode.prototype.name)(\(args))"
		
		let structDocumentation: StructDocumentation?
		
		let rawDocumentation = structNode.documentation
		if let rawDocumentation = rawDocumentation {
			
			structDocumentation = parsedStructDocumentation(rawDocumentation: rawDocumentation, members: structNode.prototype.members)
			
		} else {
			
			structDocumentation = nil
		}
		
		let functionItem = DocumentationItem(definition: definition, rawDocumentation: rawDocumentation, type: .struct, functionDocumentation: nil, variableDocumentation: nil, structDocumentation: structDocumentation, title: title)
		
		return functionItem
	}
	
	private func parsedDocumentation(for functionNode: FunctionNode) -> DocumentationItem {
		
		let args = functionNode.prototype.argumentNames.joined(separator: ", ")
		var definition = "func \(functionNode.prototype.name)(\(args))"
		var title = "\(functionNode.prototype.name)(\(args))"

		if functionNode.prototype.returns {
			definition += " returns"
			title += " returns"
		}
		
		let functionDocumentation: FunctionDocumentation?
		
		let rawDocumentation = functionNode.documentation
		if let rawDocumentation = rawDocumentation {
			
			functionDocumentation = parsedFunctionDocumentation(rawDocumentation: rawDocumentation, arguments: functionNode.prototype.argumentNames, returns: functionNode.prototype.returns)
 
		} else {
			
			functionDocumentation = nil
		}
		
		let functionItem = DocumentationItem(definition: definition, rawDocumentation: rawDocumentation, type: .function, functionDocumentation: functionDocumentation, variableDocumentation: nil, structDocumentation: nil, title: title)
		
		return functionItem
	}
	
	private func parsedFunctionDocumentation(rawDocumentation: String, arguments: [String], returns: Bool) -> FunctionDocumentation? {
		
		let rawDocLines = rawDocumentation.split(separator: "\n").map({ String($0) })
		
		let cleanedUpRawDocLines: [String] = rawDocLines.map({
			var cleanedUp = $0
			if cleanedUp.hasPrefix("///") {
				cleanedUp.removeFirst(3)
			}
			
			cleanedUp = cleanedUp.trimmingCharacters(in: .whitespaces)
			
			return cleanedUp
		})
		
		var description: String? = nil
		var endDescriptionParsing = false
		
		var argumentDescriptions = [String: String?]()
		var returnDescription: String? = nil
		
		var legalDocFields = [String: String]()
		
		for argumentName in arguments {
			
			legalDocFields["- Parameter \(argumentName):"] = argumentName
			
		}
		
		if returns {
			legalDocFields["- Returns:"] = "returns"
		}
		
		for line in cleanedUpRawDocLines {
			
			if line.starts(with: "-") {
				
				endDescriptionParsing = true
				
				for (legalDocField, name) in legalDocFields {
					
					if line.starts(with: legalDocField) {
						
						let value = String(line.dropFirst(legalDocField.count))
						
						let cleanedUpValue = value.trimmingCharacters(in: .whitespaces)
						
						if name == "returns" {
							returnDescription = cleanedUpValue
						} else {
							argumentDescriptions[name] = cleanedUpValue
						}
						
					}
					
				}
				
			} else if !endDescriptionParsing {
				
				if description == nil {
					description = line
				} else {
					
					description?.append("\n")
					description?.append(line)
					
				}
				
			}
			
		}
		
		return FunctionDocumentation(description: description, arguments: arguments, argumentDescriptions: argumentDescriptions, returnDescription: returnDescription)
	}
	
	private func parsedVariableDocumentation(rawDocumentation: String) -> VariableDocumentation? {
		
		let rawDocLines = rawDocumentation.split(separator: "\n").map({ String($0) })
		
		let cleanedUpRawDocLines: [String] = rawDocLines.map({
			var cleanedUp = $0
			if cleanedUp.hasPrefix("///") {
				cleanedUp.removeFirst(3)
			}
			
			cleanedUp = cleanedUp.trimmingCharacters(in: .whitespaces)
			
			return cleanedUp
		})
		
		var description: String? = nil
		
		for line in cleanedUpRawDocLines {
			
			if description == nil {
				description = line
			} else {
				
				description?.append("\n")
				description?.append(line)
				
			}
			
		}
		
		return VariableDocumentation(description: description)
	}
	
	private func parsedStructDocumentation(rawDocumentation: String, members: [String]) -> StructDocumentation? {

		let rawDocLines = rawDocumentation.split(separator: "\n").map({ String($0) })
		
		let cleanedUpRawDocLines: [String] = rawDocLines.map({
			var cleanedUp = $0
			if cleanedUp.hasPrefix("///") {
				cleanedUp.removeFirst(3)
			}
			
			cleanedUp = cleanedUp.trimmingCharacters(in: .whitespaces)
			
			return cleanedUp
		})
		
		var description: String? = nil
		var endDescriptionParsing = false
		
		var argumentDescriptions = [String: String?]()
		
		var legalDocFields = [String: String]()
		
		for memberName in members {
			
			legalDocFields["- \(memberName):"] = memberName
			
		}
		
		for line in cleanedUpRawDocLines {
			
			if line.starts(with: "-") {
				
				endDescriptionParsing = true
				
				for (legalDocField, name) in legalDocFields {
					
					if line.starts(with: legalDocField) {
						
						let value = String(line.dropFirst(legalDocField.count))
						
						let cleanedUpValue = value.trimmingCharacters(in: .whitespaces)
						
						argumentDescriptions[name] = cleanedUpValue

						
					}
					
				}
				
			} else if !endDescriptionParsing {
				
				if description == nil {
					description = line
				} else {
					
					description?.append("\n")
					description?.append(line)
					
				}
				
			}
			
		}
		
		return StructDocumentation(description: description, members: members, memberDescriptions: argumentDescriptions)
	}
	
}
