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

import ReactiveSwift

extension SignalProtocol {
    /// Appends each `next` value from `self` onto an ever increasing array.
    ///
    /// - returns: A signal that emits an array containing all `next` values.
    public func accumulate() -> Signal<[Value], Error> {
        return scan([]) { accum, action in
            accum + [action]
        }
    }
}

extension SignalProducerProtocol {
    /// Appends each `next` value from `self` onto an ever increasing array.
    ///
    /// - returns: A signal that emits an array containing all `next` values.
    public func accumulate() -> SignalProducer<[Value], Error> {
        return lift { $0.accumulate() }
    }
}
