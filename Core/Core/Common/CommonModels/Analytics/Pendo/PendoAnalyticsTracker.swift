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

    // MARK: Properties

    private let interactor: AnalyticsMetadataInteractor
    private let pendoManager: PendoManagerWrapper
    private var pendoApiKey: String?

    private var isSetupCalled: Bool = false
    private var isApiKeyCurrent: Bool = false
    private var isSessionInProgress: Bool = false

    // MARK: Initialization

    public init(
        interactor: AnalyticsMetadataInteractor = AnalyticsMetadataInteractorLive(),
        pendoManager: PendoManagerWrapper = PendoManager.shared(),
        pendoApiKey: String? = nil
    ) {
        self.interactor = interactor
        self.pendoManager = pendoManager

        self.pendoApiKey = pendoApiKey?.nilIfEmpty
        if pendoApiKey?.nilIfEmpty != nil {
            isApiKeyCurrent = true
        }
    }

    // MARK: - Setup & Start Session

    public func initManager(with url: URL) {
        pendoManager.initWith(url)
    }

    public func storeApiKey(_ apiKey: String) {
        if isSetupCalled && pendoApiKey != apiKey {
            // This can happen after a new login with a different api key.
            // It that case we should disable tracking,
            // since we can't resetup pendo with the new api key.
            isApiKeyCurrent = false
        } else {
            pendoApiKey = apiKey
            isApiKeyCurrent = true
        }
    }

    /// Start the session asynchronously.
    public func startSession(completion: (() -> Void)? = nil) {
        Task { [weak self] in
            try? await self?.startSessionAsync()
            completion?()
        }
    }

    // extracted for testing purposes
    internal func startSessionAsync() async throws {
        guard let pendoApiKey, isApiKeyCurrent else { return }

        await setupManagerIfNeeded(apiKey: pendoApiKey)

        let metadata = try await interactor.getMetadata()

        await startSession(withMetadata: metadata)
    }

    // Setup should be called only once during the application lifecycle.
    @MainActor
    private func setupManagerIfNeeded(apiKey: String) {
        guard !isSetupCalled else { return }

        isSetupCalled = true
        pendoManager.setup(apiKey)
    }

    @MainActor
    private func startSession(withMetadata metadata: AnalyticsMetadata) {
        AppEnvironment.shared.pendoID = metadata.userId

        // This will also terminate the current session if there is one.
        pendoManager.startSession(
            metadata.userId,
            accountId: metadata.accountUUID,
            visitorData: metadata.visitorData.toMap(),
            accountData: metadata.accountData.toMap()
        )

        isSessionInProgress = true
    }

    // MARK: - End Session

    @MainActor
    public func endSession() {
        guard let pendoApiKey, isApiKeyCurrent else { return }

        setupManagerIfNeeded(apiKey: pendoApiKey)

        isSessionInProgress = false
        pendoManager.endSession()
    }

    // MARK: - Track

    public func track(_ eventName: String, properties: [String: Any]?) {
        guard isSessionInProgress else { return }

        pendoManager.track(eventName, properties: properties)
    }
}
