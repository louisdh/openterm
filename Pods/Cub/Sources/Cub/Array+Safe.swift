//
//  Array+Safe.swift
//  Cub
//
//  Created by Louis D'hauwe on 04/11/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

extension Array {
	subscript (safe index: Int) -> Element? {
		return indices ~= index ? self[index] : nil
	}
}
