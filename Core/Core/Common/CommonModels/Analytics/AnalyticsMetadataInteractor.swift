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

public protocol AnalyticsMetadataInteractor {
    func getMetadata() async throws -> AnalyticsMetadata
}

public class AnalyticsMetadataInteractorLive: AnalyticsMetadataInteractor {

    private struct UserMetadata {
        let uuid: String?
        var locale: String?
        let accountUUID: String?
    }

    public init() {}

    public func getMetadata() async throws -> AnalyticsMetadata {
        let flagEnabledStore = ReactiveStore(useCase: GetEnvironmentFeatureFlags(context: Context.currentUser))
            .getEntities()
            .map { $0.isFeatureEnabled(.account_survey_notifications) }

        let userStore = ReactiveStore(useCase: GetSelfUserIncludingUUID())
            .getEntities(ignoreCache: true)
            .tryMap {
                guard let user = $0.first else { throw NSError.internalError() }

                return UserMetadata(uuid: user.uuid, locale: user.locale, accountUUID: user.accountUUID)
            }

        // Both stores publish non-managed-object values to avoid accessing the managed objects
        //  from arbitrary threads which happen to call this method
        async let flagEnabledPublisher = flagEnabledStore.asyncPublisher()
        async let userPublisher = userStore.asyncPublisher()

        let isFlagEnabled = try await flagEnabledPublisher
        let user = try await userPublisher

        let userUUID = user.uuid?.sha256() ?? ""
        let accountUUID = user.accountUUID ?? ""

        return AnalyticsMetadata(
            userId: userUUID,
            accountUUID: accountUUID,
            visitorData: .init(
                id: userUUID,
                locale: user.locale ?? ""
            ),
            accountData: .init(
                id: accountUUID,
                surveyOptOut: isFlagEnabled
            )
        )
    }
}

private extension Publisher {
    func asyncPublisher() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.first()
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
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
