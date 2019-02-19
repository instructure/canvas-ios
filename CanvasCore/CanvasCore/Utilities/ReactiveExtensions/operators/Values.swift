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
