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

public extension SignalProtocol where Value: Sequence {
    /**
     Transforms a signal of sequences into a signal of elements by emitting all elements of each sequence.
     - returns: A new signal.
     */
    
    public func uncollect() -> Signal<Value.Iterator.Element, Error> {
        return Signal<Value.Iterator.Element, Error> { observer in
            return self.observe { event in
                switch event {
                case let .value(sequence):
                    sequence.forEach(observer.send)
                case let .failed(error):
                    observer.send(error: error)
                case .completed:
                    observer.sendCompleted()
                case .interrupted:
                    observer.sendInterrupted()
                }
            }
        }
    }
}

public extension SignalProducerProtocol where Value: Sequence {
    /**
     Transforms a producer of sequences into a producer of elements by emitting all elements of each sequence.
     - returns: A new producer.
     */
    
    public func uncollect() -> SignalProducer<Value.Iterator.Element, Error> {
        return lift { $0.uncollect() }
    }
}
