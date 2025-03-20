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
    private let interactor: AnalyticsMetadataInteractor
    private let pendoManager: PendoManager

    private lazy var pendoApiKey: String? = {
        Secret.pendoApiKey.string?.nilIfEmpty
    }()

    private var isSetupCalled: Bool = false
    private var isSessionInProgress: Bool = false

    public init(
        environment: AppEnvironment,
        interactor: AnalyticsMetadataInteractor = AnalyticsMetadataInteractorLive(),
        pendoManager: PendoManager = .shared()
    ) {
        self.environment = environment
        self.interactor = interactor
        self.pendoManager = pendoManager
    }

    public func initManager(with url: URL) {
        pendoManager.initWith(url)
    }

    public func startSession() {
        guard let pendoApiKey else { return }

        if !isSetupCalled {
            // This should be called only once during the application lifecycle.
            pendoManager.setup(pendoApiKey)
            isSetupCalled = true
        }

        Task.detached { [weak self] in
            guard let self else { return }

            let metadata = try await interactor.getMetadata()

            environment?.pendoID = metadata.userId

            // This will also terminate the current session if there is one.
            pendoManager.startSession(
                metadata.userId,
                accountId: metadata.accountUUID,
                visitorData: metadata.visitorData.toMap(),
                accountData: metadata.accountData.toMap()
            )
            isSessionInProgress = true
        }
    }

    public func endSession() {
        isSessionInProgress = false
        pendoManager.endSession()
    }

    public func track(_ name: String, properties: [String: Any]?) {
        guard isSessionInProgress else { return }

        pendoManager.track(name, properties: properties)
    }
}
