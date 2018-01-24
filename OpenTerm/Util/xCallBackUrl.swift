//
//  xCallBackUrl.swift
//  OpenTerm
//
//  Created by Anders Borum on 24/01/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import ios_system

// mapping between uuid and completion callback
private typealias xCallback = (_ okMessage: String?, _ errroCode: Int?, _ errorMessage: String?) -> Void
private var xCallbacks = [String: xCallback]()

public func xCallbackUrlOpen(_ url: URL) -> Bool {
    // make sure the scheme is correct
    guard url.scheme == "openterm" else { return false }
    
    // uuid identifying this callback is the path except for a leading slash
    guard url.path.hasPrefix("/") else { return false }
    let uuid = String(url.path.suffix(url.path.count - 1))

    // we ignore callbacks where uuid is unknown
    guard let callback = xCallbacks[uuid] else { return false }
    
    // parse parameters
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }
    let items = components.queryItems ?? []
    
    switch url.host {

    case .some("callback-success"):
        // the last parameter is the one we want
        let success: String = items.last?.value ?? ""
        callback(success, nil, nil)
        return true

    case .some("callback-error"):
        // pass along errorCode=code and errorMessage=message
        let errorCodeString = items.first(where: { $0.name == "errorCode" })?.value ?? ""
        let errorMessage = items.first(where: { $0.name == "errorMessage" })?.value ?? ""
        guard let errorCode = Int(errorCodeString) else { return false }
        
        callback(nil, errorCode, errorMessage)
        return true

    default:
        return false
    }
}

public func xCallbackUrl(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
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
    
    // shorthand to URL escape parameters
    let escape: (String) -> String = { str in str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! }
    
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
        urlString.append(escape(string))
    }
    
    // we use a semaphore to wait for completion
    var resultOkMessage: String?
    var resultErrorCode: Int?
    var resultErrorMessage: String?
    let semaphore = DispatchSemaphore(value: 1)
    semaphore.wait()
    
    // we use a uuid to identitfy this request from others
    let uuid = UUID().uuidString
    xCallbacks[uuid] = { (okMessage, errorCode, errorMessage) in
        
        // write back results
        resultOkMessage = okMessage
        resultErrorCode = errorCode
        resultErrorMessage = errorMessage
        
        // resume x-callback-url command
        semaphore.signal()
    }
    
    // add x-success and x-error callbacks
    if !urlString.contains("?") {
        urlString.append("?")
    } else if(!urlString.hasSuffix("&")) {
        urlString.append("&")
    }
    urlString.append("x-source=OpenTerm&")
    urlString.append("x-success=\(escape("openterm://callback-success/\(uuid)/?"))&")
    urlString.append("x-error=\(escape("openterm://callback-error/\(uuid)/?"))&")

    url = URL(string: urlString)
    
    DispatchQueue.main.async {
        UIApplication.shared.open(url!, options: [:], completionHandler: { ok in
            if !ok {
                if let callback = xCallbacks[uuid] {
                    let message = "Unable to open: \(url!.absoluteString)"
                    callback(nil, 1, message)
                }
            }
        })
    }
    
    // wait for callback to be made
    semaphore.wait()
    
    // clean up callback and semaphore
    xCallbacks.removeValue(forKey: uuid)
    semaphore.signal()

    // determine result of operation
    let returnCode = Int32(resultErrorCode ?? 0)
    let outputFile = resultErrorCode == nil ? fileno(stdout) : fileno(stderr)
    let returnText = (resultErrorCode == nil ? resultOkMessage : resultErrorMessage) ?? ""
    
    // output results
    let c_string = returnText.utf8CString
    write(outputFile, c_string, strlen(c_string))
    write(outputFile, "\n", 1)

    return returnCode
}


