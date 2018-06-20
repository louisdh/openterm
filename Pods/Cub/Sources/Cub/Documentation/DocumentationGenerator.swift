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
		
		for externalVarDef in runner.externalVariables.values {
			
			let item = parsedDocumentation(for: externalVarDef)
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
		
		let rawDocumentation = assignmentNode.documentation
		
		let variableDocumentation = parsedVariableDocumentation(name: varNode.name, rawDocumentation: rawDocumentation)
		
		let varItem = DocumentationItem(definition: definition, rawDocumentation: rawDocumentation, type: .variable(variableDocumentation), title: title)
		
		return varItem
	}

	private func parsedDocumentation(for externalVarDefinition: ExternalVariableDefinition) -> DocumentationItem {

		let definition = externalVarDefinition.name
		let title = externalVarDefinition.name
		
		let rawDocumentation = externalVarDefinition.documentation

		let variableDocumentation = parsedVariableDocumentation(name: externalVarDefinition.name, rawDocumentation: rawDocumentation)
		
		let varItem = DocumentationItem(definition: definition, rawDocumentation: rawDocumentation, type: .variable(variableDocumentation), title: title)
		
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
		
		let functionDocumentation = parsedFunctionDocumentation(name: externalFunctionDefinition.name, rawDocumentation: externalFunctionDefinition.documentation, arguments: externalFunctionDefinition.argumentNames, returns: externalFunctionDefinition.returns)
		
		let functionItem = DocumentationItem(definition: definition, rawDocumentation: externalFunctionDefinition.documentation, type: .function(functionDocumentation), title: title)
		
		return functionItem
	}
	
	private func parsedDocumentation(for structNode: StructNode) -> DocumentationItem {
		
		let args = structNode.prototype.members.joined(separator: ", ")
		let definition = "struct \(structNode.prototype.name)(\(args))"
		let title = "\(structNode.prototype.name)(\(args))"
		
		let rawDocumentation = structNode.documentation

		let structDocumentation = parsedStructDocumentation(name: structNode.prototype.name, rawDocumentation: rawDocumentation, members: structNode.prototype.members)
		
		let functionItem = DocumentationItem(definition: definition, rawDocumentation: rawDocumentation, type: .struct(structDocumentation), title: title)
		
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
		
		let rawDocumentation = functionNode.documentation

		let functionDocumentation = parsedFunctionDocumentation(name: functionNode.prototype.name, rawDocumentation: rawDocumentation, arguments: functionNode.prototype.argumentNames, returns: functionNode.prototype.returns)
		
		let functionItem = DocumentationItem(definition: definition, rawDocumentation: rawDocumentation, type: .function(functionDocumentation), title: title)
		
		return functionItem
	}
	
	private func parsedFunctionDocumentation(name: String, rawDocumentation: String?, arguments: [String], returns: Bool) -> FunctionDocumentation {
		
		if let rawDocumentation = rawDocumentation {
			
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
			
			var argumentDescriptions = [String: String]()
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
			
			return FunctionDocumentation(name: name, arguments: arguments, returns: returns, description: description, argumentDescriptions: argumentDescriptions, returnDescription: returnDescription)

		} else {
			
			return FunctionDocumentation(name: name, arguments: arguments, returns: returns, description: nil, argumentDescriptions: [:], returnDescription: nil)

		}

	}
	
	private func parsedVariableDocumentation(name: String, rawDocumentation: String?) -> VariableDocumentation {
		
		if let rawDocumentation = rawDocumentation {
			
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
			
			return VariableDocumentation(name: name, description: description)

		} else {
			
			return VariableDocumentation(name: name, description: nil)

		}
		
	}
	
	private func parsedStructDocumentation(name: String, rawDocumentation: String?, members: [String]) -> StructDocumentation {

		if let rawDocumentation = rawDocumentation {
			
			
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
			
			var argumentDescriptions = [String: String]()
			
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
			
			return StructDocumentation(name: name, description: description, members: members, memberDescriptions: argumentDescriptions)
			
		} else {
			
			return StructDocumentation(name: name, description: nil, members: members, memberDescriptions: [:])

		}
		
	}
	
}
