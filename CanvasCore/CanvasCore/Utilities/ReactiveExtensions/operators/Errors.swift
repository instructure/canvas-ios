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
     - returns: A signal of errors of `Error` events from a materialized signal.
     */
    public func errors() -> Signal<Value.Error, NoError> {
        return self.signal.map { $0.event.error }.skipNil()
    }
}

extension SignalProducerProtocol where Value: EventProtocol, Error == NoError {
    /**
     - returns: A producer of errors of `Error` events from a materialized signal.
     */
    public func errors() -> SignalProducer<Value.Error, NoError> {
        return self.lift { $0.errors() }
    }
}
