//
//  LogHelper.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 11/20/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import Foundation
import DJISDK


public func logDebug<T>(_ object: T?, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    let logText = convertToString(object)
    DJIRemoteLogger.log(with: .debug, file: String(describing: file), function: String(describing: function), line: line, string: logText)
}

public func logInfo<T>(_ object: T?, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    let logText = convertToString(object)
    DJIRemoteLogger.log(with: .info, file: String(describing: file), function: String(describing: function), line: line, string: logText)
}

public func logWarn<T>(_ object: T?, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    let logText = convertToString(object)
    DJIRemoteLogger.log(with: .warn, file: String(describing: file), function: String(describing: function), line: line, string: logText)
}

public func logVerbose<T>(_ object: T?, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    let logText = convertToString(object)
    DJIRemoteLogger.log(with: .verbose, file: String(describing: file), function: String(describing: function), line: line, string: logText)
}

public  func logError<T>(_ object: T?, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    let logText = convertToString(object)
    DJIRemoteLogger.log(with: .error, file: String(describing: file), function: String(describing: function), line: line, string: logText)
}

func convertToString<T>(_ objectOpt: T?) -> String
{
    if let object = objectOpt
    {
        switch object
        {
        case let error as NSError:
            let localizedDesc = error.localizedDescription
            if !localizedDesc.isEmpty { return "\(error.domain) : \(error.code) : \(localizedDesc)" }
            return "<<\(error.localizedDescription)>> --- ORIGINAL ERROR: \(error)"
        case let nsobject as NSObject:
            if nsobject.responds(to: #selector(NSObject.debugDescription as () -> String)) {
                return nsobject.debugDescription
            }
            else
            {
                return nsobject.description
            }
        default:
            return "\(object)"
        }
    }
    else
    {
        return "nil"
    }
    
}
