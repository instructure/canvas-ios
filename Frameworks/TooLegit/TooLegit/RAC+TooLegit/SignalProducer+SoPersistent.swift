//
//  SignalProducer+SoPersistent.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 1/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Marshal
import Result

public func attemptProducer<Value>(file: String = #file, line: UInt = #line, @noescape f: () throws -> Value) -> SignalProducer<Value, NSError> {
    do {
        return SignalProducer(value: try f())
    } catch let e as Marshal.Error {
        return SignalProducer(error: NSError(jsonError: e, file: file, line: line))
    } catch let e as NSError {
        return SignalProducer(error: e.addingInfo(file, line: line))
    }
}

public func blockProducer<Value>(f: () -> Value) -> SignalProducer<Value, NoError> {
    return SignalProducer<()->Value, NoError>(value: f).map { $0() }
}
