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

final class AnalyticsConsentInteractorMock: AnalyticsConsentInteractor {

    // MARK: - isTrackingEnabled

    var isTrackingEnabledResult: Bool? = false

    func isTrackingEnabled(ignoreConsentCache: Bool) -> AnyPublisher<Bool?, Error> {
        Publishers.typedJust(isTrackingEnabledResult)
    }

    // MARK: - getConsentIfRequired

    var getConsentIfRequiredResult: Bool?

    func getConsentIfRequired(ignoreConsentCache: Bool) -> AnyPublisher<Bool?, Error> {
        Publishers.typedJust(getConsentIfRequiredResult)
    }

    // MARK: - setConsent

    var setConsentCallCount = 0
    var setConsentInput: Bool?

    func setConsent(_ value: Bool) -> AnyPublisher<Void, Error> {
        setConsentInput = value
        setConsentCallCount += 1
        return Publishers.typedJust()
    }
}
