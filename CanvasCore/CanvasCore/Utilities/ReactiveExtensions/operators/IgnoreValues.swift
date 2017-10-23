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

public extension SignalProtocol {

    /**
     Creates a new signal that emits a void value for every emission of `self`.
     - returns: A new signal.
     */
    public func ignoreValues() -> Signal<Void, Error> {
        return signal.map { _ in () }
    }
}

public extension SignalProducerProtocol {

    /**
     Creates a new producer that emits a void value for every emission of `self`.
     - returns: A new producer.
     */
    public func ignoreValues() -> SignalProducer<Void, Error> {
        return lift { $0.ignoreValues() }
    }
}
