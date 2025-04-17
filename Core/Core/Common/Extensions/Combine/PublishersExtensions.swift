//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Foundation

extension Publishers {

    public static func noInstanceFailure<Output>(
        output outputType: Output.Type = Output.self
    ) -> AnyPublisher<Output, Error> {
        typedFailure(output: outputType, message: "No Instance!")
    }

    public static func typedFailure<Output>(
        output outputType: Output.Type = Output.self,
        message: String = ""
    ) -> AnyPublisher<Output, Error> {
        Fail(error: NSError.instructureError(message) as Error)
            .setOutputType(to: outputType)
            .eraseToAnyPublisher()
    }

    public static func typedEmpty<Output, Failure: Error>(
        outputType: Output.Type = Output.self,
        failureType: Failure.Type = Failure.self
    ) -> AnyPublisher<Output, Failure> {
        return Empty()
            .setOutputType(to: outputType)
            .setFailureType(to: failureType)
            .eraseToAnyPublisher()
    }

    public static func typedJust<Output, Failure: Error>(_ value: Output, failureType: Failure.Type = Failure.self) -> AnyPublisher<Output, Failure> {
        return Just(value).setFailureType(to: failureType).eraseToAnyPublisher()
    }

    public static func typedJust<Failure: Error>(failureType: Failure.Type) -> AnyPublisher<Void, Failure> {
        return Just(()).setFailureType(to: failureType).eraseToAnyPublisher()
    }
}
