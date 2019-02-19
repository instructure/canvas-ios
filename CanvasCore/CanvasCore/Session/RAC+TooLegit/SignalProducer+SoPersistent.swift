//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
