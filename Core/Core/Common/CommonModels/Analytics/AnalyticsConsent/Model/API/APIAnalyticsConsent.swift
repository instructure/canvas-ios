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

import Foundation

public struct APIAnalyticsConsent: Codable, Equatable {

    enum HandledMessage: String, CaseIterable {
        /// Received if the user hadn't yet provided or refused their consent.
        case noData = "no data for scope"

        /// Received if the consent data got messed up somehow.
        /// Handling this allows the user to "fix" this by chosing again.
        case invalidData = "invalid scope for hash"
    }

    let data: Data?
    let message: String?

    struct Data: Codable, Equatable {
        let mobile_consent: Bool?
    }

    var isValid: Bool {
        message == nil || HandledMessage.allCases.map(\.rawValue).contains(message)
    }
}

extension APIAnalyticsConsent {
    init(mobileConsentValue: Bool) {
        self.init(data: .init(mobile_consent: mobileConsentValue), message: nil)
    }
}

#if DEBUG
extension APIAnalyticsConsent {
    static func make(
        data: Data? = nil,
        message: String? = nil
    ) -> APIAnalyticsConsent {
        APIAnalyticsConsent(data: data, message: message)
    }
}
#endif
