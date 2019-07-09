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
     Creates a new signal that emits a void value for every emission of `self`.
     - returns: A new signal.
     */
    public func ignoreValues() -> Signal<Void, Error> {
        return signal.map { _ in () }
    }
}

extension SignalProducerProtocol {

    /**
     Creates a new producer that emits a void value for every emission of `self`.
     - returns: A new producer.
     */
    public func ignoreValues() -> SignalProducer<Void, Error> {
        return producer.lift { $0.ignoreValues() }
    }
}
