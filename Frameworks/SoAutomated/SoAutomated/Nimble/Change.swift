//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import Nimble

public protocol DeltaArithmetic {
    func +(lhs: Self, rhs: Self) -> Self
}

extension Int8 : DeltaArithmetic {}
extension Int16 : DeltaArithmetic {}
extension Int32 : DeltaArithmetic {}
extension Int64 : DeltaArithmetic {}
extension Int : DeltaArithmetic {}

extension UInt8 : DeltaArithmetic {}
extension UInt16 : DeltaArithmetic {}
extension UInt32 : DeltaArithmetic {}
extension UInt64 : DeltaArithmetic {}

extension Float : DeltaArithmetic {}
extension Double : DeltaArithmetic {}

private let changeRequiresClosureError = FailureMessage(stringValue: "expect(...).(to|toNot)(change(...)) requires an explicit closure (eg - expect { ... }.to(change(...)) )")

public func change<T: Equatable>(_ value: @escaping (Void) -> T?) -> MatcherFunc<Void> {
    return MatcherFunc { expression, failureMessage in
        guard expression.isClosure else {
            failureMessage.stringValue = changeRequiresClosureError.stringValue
            return false
        }

        let before = value()
        try expression.evaluate()
        let after = value()
        
        failureMessage.postfixMessage = "change"
        failureMessage.postfixActual += " <\(stringify(after))>"
        
        return before != after
    }
}

private func didChange<T, U>(_ value: (Void) -> T?, expression: Expression<U>, from: T?, to: T?, failureMessage: FailureMessage) throws -> Bool where T: Equatable {
    guard expression.isClosure else {
        failureMessage.stringValue = changeRequiresClosureError.stringValue
        return false
    }
    
    let before = value()
    
    try expression.evaluate()
    let after = value()
    
    failureMessage.postfixMessage = "change to <\(stringify(to))> from <\(stringify(from))>"
    failureMessage.postfixActual = "<\(stringify(after))> from <\(stringify(before))>"

    return before == from && after == to
}

public func change<T>(_ value: @escaping (Void) -> T, by expectedDelta: T) -> MatcherFunc<Void> where T: Equatable, T: DeltaArithmetic {
    return MatcherFunc { expression, failureMessage in
        return try didChange(value, expression: expression, from: value(), to: value() + expectedDelta, failureMessage: failureMessage)
    }
}

public func change<T>(_ value: @escaping (Void) -> T?, from: T?, to: T?) -> MatcherFunc<Void> where T: Equatable {
    return MatcherFunc { expression, failureMessage in
        return try didChange(value, expression: expression, from: from, to: to, failureMessage: failureMessage)
    }
}

public func change<T>(_ value: @escaping (Void) -> T?, to: T?) -> MatcherFunc<Void> where T: Equatable {
    return MatcherFunc { expression, failureMessage in
        let before = value()
        
        guard before != to else {
            failureMessage.stringValue = "original value should not equal the desired change value"
            return false
        }
        
        try expression.evaluate()
        let after = value()
        
        failureMessage.postfixMessage = " change to <\(stringify(to))>"
        failureMessage.postfixActual = "<\(stringify(to))>"
        
        return before != to && after == to
    }
}
