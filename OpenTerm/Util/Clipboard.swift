//
//  Clipboard.swift
//  OpenTerm
//
//  Created by Majid Jabrayilov on 2/1/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import ios_system

public func pbpaste(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
    fputs(UIPasteboard.general.string ?? "", thread_stdout)
    return 0
}

public func pbcopy(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
    var bytes = [Int8]()
    while true {
        var byte: Int8 = 0
        let count = read(fileno(thread_stdin), &byte, 1)
        guard count == 1 else { break }
        bytes.append(byte)
    }

    let data = Data(bytes: bytes, count: bytes.count)
    guard data.count > 0 else { return 1 }
    UIPasteboard.general.string = String(data: data, encoding: .utf8)
    return 0
}

