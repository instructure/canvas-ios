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
