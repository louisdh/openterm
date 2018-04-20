//
//  Token.swift
//  SavannaKit iOS
//
//  Created by Louis D'hauwe on 04/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public protocol Token {
	
	var savannaTokenType: TokenType { get }
	
	var range: Range<Int>? { get }
	
}

struct CachedToken {
	
	let token: Token
	let nsRange: NSRange?
	
}
