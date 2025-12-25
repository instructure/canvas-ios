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
    func getMetadata(_ completion: @escaping (Result<AnalyticsMetadata, Error>) -> Void)
}

public class AnalyticsMetadataInteractorLive: AnalyticsMetadataInteractor {

    private struct UserMetadata {
        let uuid: String?
        var locale: String?
        let accountUUID: String?
    }

    private lazy var featureFlagsStore = ReactiveStore(useCase: GetEnvironmentFeatureFlags(context: Context.currentUser))
    private lazy var userMetadataStore = ReactiveStore(useCase: GetSelfUserIncludingUUID())
    private var subscriptions = Set<AnyCancellable>()

    public init() {}

    public func getMetadata(_ completion: @escaping (Result<AnalyticsMetadata, any Error>) -> Void) {

        let isFlagEnabledPublisher = featureFlagsStore
            .getEntities()
            .map { $0.isFeatureEnabled(.account_survey_notifications) }

        let userMetadataPublisher = userMetadataStore
            .getEntities(ignoreCache: true)
            .tryMap {
                guard let user = $0.first else { throw NSError.internalError() }
                return UserMetadata(
                    uuid: user.uuid,
                    locale: user.locale,
                    accountUUID: user.accountUUID
                )
            }

        return Publishers
            .CombineLatest(isFlagEnabledPublisher, userMetadataPublisher)
            .receive(on: DispatchQueue.main)
            .map { (isFlagEnabled, userMetadata) in

                let userUUID = userMetadata.uuid?.sha256() ?? ""
                let accountUUID = userMetadata.accountUUID ?? ""

                return AnalyticsMetadata(
                    userId: userUUID,
                    accountUUID: accountUUID,
                    visitorData: .init(
                        id: userUUID,
                        locale: userMetadata.locale ?? ""
                    ),
                    accountData: .init(
                        id: accountUUID,
                        surveyOptOut: isFlagEnabled
                    )
                )
            }
            .sinkFailureOrValue(receiveFailure: { error in
                completion(.failure(error))
            }, receiveValue: { metadata in
                completion(.success(metadata))
            })
            .store(in: &subscriptions)
    }
}
