//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

@testable import Core
import Combine
import Foundation

public final class AnalyticsHandlerMock: AnalyticsHandler {

    public init() { }

    // MARK: - initializeTracking

    public func initializeTracking(sessionStartCompletion: @escaping () -> Void) -> AnyPublisher<Void, Error> {
        Publishers.typedJust()
    }

    // MARK: - endTracking

    public func endTracking() { }

    // MARK: - handleEvent

    public var handleEventInput: (name: String, parameters: [String: Any]?)?
    public var handleEventCallCount = 0

    public func handleEvent(_ name: String, parameters: [String: Any]?) {
        handleEventInput = (name, parameters)
        handleEventCallCount += 1
    }

    // MARK: - handlePendoPairingModeUrl

    public func handlePendoPairingModeUrl(url: URL) -> Bool { false }
}
