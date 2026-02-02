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
import CombineExt
import CoreData
import Foundation

extension Publisher {
    /// Sinks the publisher and ignores both completion and value events.
    public func sink() -> AnyCancellable {
        sink { _ in } receiveValue: { _ in }
    }

    public func sinkFailureOrValue(
        receiveFailure: @escaping (Self.Failure) -> Void,
        receiveValue: @escaping (Self.Output) -> Void
    ) -> AnyCancellable {
        sink(
            receiveCompletion: { completion in
                if let error = completion.error {
                    receiveFailure(error)
                }
            },
            receiveValue: receiveValue
        )
    }

    public func bindProgress(_ isLoading: PassthroughRelay<Bool>) -> AnyPublisher<Output, Failure> {
        handleEvents(
            receiveSubscription: { _ in
                isLoading.accept(true)
            },
            receiveCompletion: { _ in
                isLoading.accept(false)
            }
        )
        .eraseToAnyPublisher()
    }

    public func asyncPublisher() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.first()
                .sink(receiveCompletion: { completion in
                    if let error = completion.error {
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                }, receiveValue: { value in
                    continuation.resume(returning: value)
                    cancellable?.cancel()
                })
        }
    }

    // MARK: Ignore Errors Helpers

    public func ignoreForbiddenNotFoundErrors(replacingWith value: Output) -> AnyPublisher<Output, Failure> {
        ignoreErrors({ $0.isForbidden || $0.isNotFound }, replacingWith: value)
    }

    public func ignoreErrors(_ check: @escaping (Error) -> Bool, replacingWith value: Output) -> AnyPublisher<Output, Failure> {
        return self.catch { error in
            if check(error) {
                return Publishers.typedJust(value, failureType: Failure.self)
            }
            return Publishers.typedFailure(error: error)
        }
        .eraseToAnyPublisher()
    }
}
