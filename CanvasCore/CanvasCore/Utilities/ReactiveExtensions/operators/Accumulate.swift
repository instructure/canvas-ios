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
    /// Appends each `next` value from `self` onto an ever increasing array.
    ///
    /// - returns: A signal that emits an array containing all `next` values.
    public func accumulate() -> Signal<[Value], Error> {
        return signal.scan([]) { accum, action in
            accum + [action]
        }
    }
}

extension SignalProducerProtocol {
    /// Appends each `next` value from `self` onto an ever increasing array.
    ///
    /// - returns: A signal that emits an array containing all `next` values.
    public func accumulate() -> SignalProducer<[Value], Error> {
        return producer.lift { $0.accumulate() }
    }
}
