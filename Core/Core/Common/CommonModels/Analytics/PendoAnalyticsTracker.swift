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

import Foundation
import Pendo

public final class PendoAnalyticsTracker {

    private weak var environment: AppEnvironment?
    private let pendoManager: PendoManager

    public init(environment: AppEnvironment, pendoManager: PendoManager = .shared()) {
        self.environment = environment
        self.pendoManager = pendoManager
    }

    public func initManager(with url: URL) {
        pendoManager.initWith(url)
    }

    public func initializeTracking(environmentFeatureFlags: [FeatureFlag]) {
        guard let pendoApiKey = Secret.pendoApiKey.string?.nilIfEmpty else {
            return
        }

        guard environmentFeatureFlags.isFeatureEnabled(.send_usage_metrics) else {
            pendoManager.endSession()
            return
        }

        Task.detached { [weak environment, weak pendoManager] in
            let metadata = try await AnalyticsMetadataInteractorLive().getMetadata()

            environment?.pendoID = metadata.userId

            pendoManager?.setup(pendoApiKey)
            pendoManager?.startSession(
                metadata.userId,
                accountId: metadata.accountUUID,
                visitorData: metadata.visitorData.toMap(),
                accountData: metadata.accountData.toMap()
            )
        }
    }

    public func disableTracking() {
        pendoManager.endSession()
    }

    public func track(_ name: String, properties: [String: Any]?, environmentFeatureFlags: [FeatureFlag]) {
        guard environmentFeatureFlags.isFeatureEnabled(.send_usage_metrics) else { return }

        pendoManager.track(name, properties: properties)
    }
}
