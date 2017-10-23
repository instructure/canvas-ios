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
import Result

extension SignalProtocol where Value: EventProtocol, Error == NoError {
    /**
     - returns: A signal of values of `Next` events from a materialized signal.
     */
    public func values() -> Signal<Value.Value, NoError> {
        return self.signal.map { $0.event.value }.skipNil()
    }
}

extension SignalProducerProtocol where Value: EventProtocol, Error == NoError {
    /**
     - returns: A producer of values of `Next` events from a materialized signal.
     */
    public func values() -> SignalProducer<Value.Value, NoError> {
        return lift { $0.values() }
    }
}
