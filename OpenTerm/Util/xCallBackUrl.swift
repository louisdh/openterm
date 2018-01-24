//
//  xCallBackUrl.swift
//  OpenTerm
//
//  Created by Anders Borum on 24/01/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import ios_system

func xCallbackUrl(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
    var url: URL? = nil
    if argc == 2 {
        let urlString = String(cString: argv![1]!)
        url = URL(string: urlString)
    }
    
    guard url != nil else {
        fputs("""
usage: x-callback-url scheme://x-callback-url/command
where standard input is url encoded and appended to url.
""", stderr)
        return 1
    }
    
    // read everything from stdin and put this on url, but this should not be done
    // on a byte-by-byte basis as this makes it really hard to support Unicode
    var urlString = url!.absoluteString
    var ch: Int8 = 0;
    while true {
        let count = read(fileno(stdin), &ch, 1)
        guard count == 1 else {
            //fputs("Unable to read STDIN: \(errno)", stderr)
            break
        }
        
        let u = UnicodeScalar(Int(ch))!
        let char = Character(u)
        let string = String(char)
        let escaped = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        urlString.append(escaped)
    }
    
    url = URL(string: urlString)
    puts("\(url!.absoluteString)")
    
    DispatchQueue.main.async {
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    // we would like to wait for completion handler to tell us if opening worked,
    // but we are not there yet
    let couldOpenUrl = true
    guard couldOpenUrl else {
        fputs("Error opening '\(url!.absoluteString)'", stderr)
        return 1
    }
    
    // echo Hello World > hello
    // x-callback-url mailto:?body= < hello
    
    // test redirection:
    //   grep e < hello
    
    // echo Hello World | x-callback-url mailto:?body=
    
    // puts("\(url!.absoluteString)")
    return 0
}


