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
import ReactiveSwift
import Marshal
import Result

public func attemptProducer<Value>(_ file: String = #file, line: UInt = #line, f: () throws -> Value) -> SignalProducer<Value, NSError> {
    do {
        return SignalProducer(value: try f())
    } catch let e as MarshalError {
        return SignalProducer(error: NSError(jsonError: e, parsingObjectOfType: Value.self, file: file, line: line))
    } catch let e as NSError {
        return SignalProducer(error: e.addingInfo(file, line: line))
    }
}

public func blockProducer<Value>(_ f: @escaping () -> Value) -> SignalProducer<Value, NoError> {
    return SignalProducer<()->Value, NoError>(value: f).map { $0() }
}
