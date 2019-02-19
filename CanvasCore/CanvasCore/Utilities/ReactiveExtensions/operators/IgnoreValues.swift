//
// Copyright (C) 2017-present Instructure, Inc.
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
