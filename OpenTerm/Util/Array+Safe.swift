//
//  Array+Safe.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 11/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

extension Collection {
	
	/// Returns the element at the specified index iff it is within bounds, otherwise nil.
	subscript(safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
	
}
