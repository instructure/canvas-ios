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

public protocol AnalyticsMetadataInteractor {
    func getMetadata() -> AnalyticsMetadata
}

public class AnalyticsMetadataInteractorLive: AnalyticsMetadataInteractor {
    private let loginSession: LoginSession
    private let environmentFeatureFlags: Store<GetEnvironmentFeatureFlags>

    public init?(
        loginSession: LoginSession?,
        environment: AppEnvironment = .shared
    ) {
        if let loginSession {
            self.loginSession = loginSession
        } else {
            return nil
        }

        self.environmentFeatureFlags = environment
            .subscribe(
                GetEnvironmentFeatureFlags(
                    context: Context.currentUser
                )
            )
            .refresh()
    }

    public func getMetadata() -> AnalyticsMetadata {
        let userId = loginSession.hashedUserId()
        let accountId = ""
        return AnalyticsMetadata(
            userId: userId,
            accountUUID: accountId,
            visitorData: .init(
                id: userId,
                locale: loginSession.locale ?? ""
            ),
            accountData: .init(
                id: accountId,
                surveyOptOut: environmentFeatureFlags.isFeatureEnabled(.account_survey_notifications)
            )
        )
    }
}
