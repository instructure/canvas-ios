//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import ReactiveSwift

public extension SignalProtocol where Value: Sequence {
    /**
     Transforms a signal of sequences into a signal of elements by emitting all elements of each sequence.
     - returns: A new signal.
     */
    
    func uncollect() -> Signal<Value.Iterator.Element, Error> {
        return Signal<Value.Iterator.Element, Error> { observer, _ in
            signal.observe { event in
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
    
    func uncollect() -> SignalProducer<Value.Iterator.Element, Error> {
        return producer.lift { $0.uncollect() }
    }
}
