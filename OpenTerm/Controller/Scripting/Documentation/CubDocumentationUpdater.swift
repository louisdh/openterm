//
//  CubDocumentationUpdater.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 21/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import Cub

/// The Cub documentation is included in the app bundle.
/// Use this function to update the docs during development.
func getCubDocumentationBundle(for runner: Runner) -> CubDocumentationBundle {
	
	let generator = DocumentationGenerator()
	let items = generator.items(runner: runner)
	
	return CubDocumentationBundle(items: items)
}

func getCubDocumentationBundleAsJSON(for runner: Runner) throws -> String? {
	
	let bundle = getCubDocumentationBundle(for: runner)
	
	let encoder = JSONEncoder()
	let data = try encoder.encode(bundle)
	
	let string = String(data: data, encoding: .utf8)
	
	return string
}

func getCubDocumentationBundleAsJSON() -> String? {

	let dummyCmdExecutor = CommandExecutor()
	let dummyDelegate = TerminalView()
	
	let runner = Runner.runner(executor: dummyCmdExecutor, executorDelegate: dummyDelegate, parametersCallback: {
		return .array([])
	})

	guard let json = try? getCubDocumentationBundleAsJSON(for: runner) else {
		return nil
	}
	
	return json
}
