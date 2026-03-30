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

public protocol AnalyticsConsentInteractor {
    func getConsent() -> AnyPublisher<Bool?, Error>
    func setConsent(_ value: Bool) -> AnyPublisher<Void, Error>
}

public class AnalyticsConsentInteractorLive: AnalyticsConsentInteractor {

    private let environment: AppEnvironment

    public init(environment: AppEnvironment = AppEnvironment.shared) {
        self.environment = environment
    }

    public func getConsent() -> AnyPublisher<Bool?, Error> {
        GetAnalyticsConsentFlag()
            .fetchWithAPIResponse(environment: environment)
            .map { response, _ in
                guard let data = response?.data else { return nil }
                return data == "true"
            }
            .eraseToAnyPublisher()
    }

    public func setConsent(_ value: Bool) -> AnyPublisher<Void, Error> {
        SetAnalyticsConsentFlag(value: value)
            .fetchWithFuture(environment: environment)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
