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

extension SignalProtocol {

    /**
     Concats a sequence of signals into a single signal.
     - parameter signals: A sequence of signals.
     - returns: A concatenated signal.
     */
    public static func concat<Seq: Sequence>(_ signals: Seq) -> Signal<Value, Error> where Seq.Iterator.Element == Signal<Value, Error> {
        var result: Signal<Value, Error>!
        SignalProducer<Signal<Value, Error>, Error>(signals).startWithSignal { signal, _ in
            result = signal.flatten(.concat)
        }
        return result
    }

    public static func concat<Value, Error>(_ signals: Signal<Value, Error>...) -> Signal<Value, Error> {
        return Signal.concat(signals)
    }
}

extension SignalProducerProtocol {
    /**
     Concats a sequence of producers into a single producer.
     - parameter producers: A sequence of producers.
     - returns: A concatenated producer.
     */
    public static func concat<Seq: Sequence>(_ producers: Seq) -> SignalProducer<Value, Error> where Seq.Iterator.Element == SignalProducer<Value, Error> {
        return SignalProducer(producers).flatten(.concat)
    }

    public static func concat<Value, Error>(_ producers: SignalProducer<Value, Error>...) -> SignalProducer<Value, Error> {
        return SignalProducer.concat(producers)
    }
}
