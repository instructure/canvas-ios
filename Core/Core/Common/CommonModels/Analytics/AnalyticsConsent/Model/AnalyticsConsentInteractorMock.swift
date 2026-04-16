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

import Combine
import Foundation

public final class AnalyticsConsentInteractorMock: AnalyticsConsentInteractor {

    public init() { }

    // MARK: - isTrackingEnabled

    public var isTrackingEnabledResult: Bool? = false

    public func isTrackingEnabled(ignoreConsentCache: Bool) -> AnyPublisher<Bool?, Error> {
        Publishers.typedJust(isTrackingEnabledResult)
    }

    // MARK: - getConsentIfRequired

    public var getConsentIfRequiredResult: Bool?

    public func getConsentIfRequired(ignoreConsentCache: Bool) -> AnyPublisher<Bool?, Error> {
        Publishers.typedJust(getConsentIfRequiredResult)
    }

    // MARK: - setConsent

    public var setConsentCallCount = 0
    public var setConsentInput: Bool?
    public var setConsentPublisher: AnyPublisher<Void, Error>?

    public func setConsent(_ value: Bool) -> AnyPublisher<Void, Error> {
        setConsentInput = value
        setConsentCallCount += 1
        return setConsentPublisher ?? Publishers.typedJust()
    }
}
