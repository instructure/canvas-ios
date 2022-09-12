//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine

extension Future where Output == Void {

    /** This helper method is for use-cases when the subscriber is not interested in the received value from this `Future` only in the completion. */
    public func sink(receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void)) -> AnyCancellable {
        sink(receiveCompletion: receiveCompletion, receiveValue: {})
    }
}

extension Array where Element: Future<Void, Error> {

    /**
     - returns: A `Future` that finishes when all `Future`s finish in this `Array`.
     If any of the `Future`s fail, then this `Future` will also fail with the error of the failed upstream `Future`.
     */
    public func allFinished() -> Future<Void, Error> {
        let future = Future<Void, Error> { promise in
            // This subscription is kept alive with a retain cycle,
            // the subscription keeps alive the publisher and the publisher
            // keeps a strong ref to the subscription. The cycle breaks
            // when we receive a completion from the upstream publishers.
            var subscription: AnyCancellable?
            subscription = Publishers
                .MergeMany(self)
                .collect()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                        subscription?.cancel()
                        subscription = nil
                    },
                    receiveValue: { _ in
                        promise(.success(()))
                    })
        }
        return future
    }
}
