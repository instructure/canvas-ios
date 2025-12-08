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
}

extension Publisher {

    /// Replaces error with a specified value.
    /// - Parameters:
    ///   - value: The value to replace errors with.
    ///   - failureType: The failure type to use for the publisher.
    /// - Returns: A publisher that emits the specified value on error.
    public func catchErrorReplacing<F>(with value: Output, failureType: F.Type = F.self) -> Publishers.Catch<Self, Result<Output, F>.Publisher> where F: Error {
        return self
            .catch({ _ in
                Just(value)
                    .setFailureType(to: failureType)
            })
    }

    /// Replaces error with a specified value. Results in a publisher with the same Failure type as the original publisher.
    /// - Parameters:
    ///   - value: The value to replace errors with.
    /// - Returns: A publisher that emits the specified value on error, with the same Failure type as the original publisher.
    public func catchErrorReplacing(with value: Output) -> Publishers.Catch<Self, Result<Output, Failure>.Publisher> {
        return self
            .catch({ _ in
                Just(value)
                    .setFailureType(to: Failure.self)
            })
    }

    /// Replaces error with a void value.
    /// - Parameter failureType: The failure type to use for the publisher.
    /// - Returns: A publisher that emits void value on error.
    public func catchErrorReplacingWithVoid<F>(failureType: F.Type = F.self) -> Publishers.Catch<Self, Result<Output, F>.Publisher> where Output == Void, F: Error {
        return self
            .catch({ _ in
                Just(()).setFailureType(to: failureType)
            })
    }

    /// Replaces error with a void value. Results in a publisher with the same Failure type as the original publisher.
    /// - Returns: A publisher that emits void value on error, with the same Failure type as the original publisher.
    public func catchErrorReplacingWithVoid() -> Publishers.Catch<Self, Result<Output, Failure>.Publisher> where Output == Void {
        return self
            .catch({ _ in
                Just(()).setFailureType(to: Failure.self)
            })
    }
}
