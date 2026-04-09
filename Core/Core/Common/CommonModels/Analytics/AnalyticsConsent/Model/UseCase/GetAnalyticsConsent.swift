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

import CoreData
import Foundation

struct GetAnalyticsConsent: APIUseCase {
    typealias Model = CDAnalyticsConsent

    let cacheKey: String? = "get-analytics-consent"
    let request: GetAnalyticsConsentRequest

    init(app: AppEnvironment.App) {
        self.request = .init(namespace: app.consentNamespace)
    }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping (APIAnalyticsConsent?, URLResponse?, Error?) -> Void) {
        // There are error cases which are considered valid responses,
        // so we need this custom `makeRequest()` implementation to handle that.
        environment.api.makeRequest(request) { response, urlResponse, error in
            if let error {
                completionHandler(nil, urlResponse, error)
                return
            }

            guard let response else {
                completionHandler(nil, urlResponse, NSError.internalError())
                return
            }

            guard response.isValid else {
                completionHandler(nil, urlResponse, NSError.internalError())
                return
            }

            completionHandler(response, urlResponse, nil)
        }
    }
}
