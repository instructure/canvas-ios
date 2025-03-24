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

// This is only needed to make testing possible
public protocol PendoManagerWrapper: AnyObject {
    func initWith(_ url: URL)
    func setup(_ appKey: String)
    func startSession(_ visitorId: String?, accountId: String?, visitorData: [AnyHashable: Any]?, accountData: [AnyHashable: Any]?)
    func endSession()
    func track(_ event: String, properties: [AnyHashable: Any]?)
}

extension PendoManager: PendoManagerWrapper {}

public final class PendoAnalyticsTracker {

    private weak var environment: AppEnvironment?
    private let interactor: AnalyticsMetadataInteractor
    private let pendoManager: PendoManagerWrapper

    private lazy var pendoApiKey: String? = {
        Secret.pendoApiKey.string?.nilIfEmpty
    }()

    private var isSetupCalled: Bool = false
    private var isSessionInProgress: Bool = false

    public init(
        environment: AppEnvironment,
        interactor: AnalyticsMetadataInteractor = AnalyticsMetadataInteractorLive(),
        pendoManager: PendoManagerWrapper = PendoManager.shared()
    ) {
        self.environment = environment
        self.interactor = interactor
        self.pendoManager = pendoManager
    }

    public func initManager(with url: URL) {
        pendoManager.initWith(url)
    }

    // Setup should be called only once during the application lifecycle.
    private func setupManagerIfNeeded(apiKey: String) {
        guard !isSetupCalled else { return }

        isSetupCalled = true
        pendoManager.setup(apiKey)
    }

    /// Start the session asynchronously
    public func startSession() {
        Task { [weak self] in
            try? await self?.startSessionAsync()
        }
    }

    // extracted for testing purposes
    internal func startSessionAsync() async throws {
        guard let pendoApiKey else { return }
        setupManagerIfNeeded(apiKey: pendoApiKey)

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

    public func endSession() {
        guard let pendoApiKey else { return }
        setupManagerIfNeeded(apiKey: pendoApiKey)

        isSessionInProgress = false
        pendoManager.endSession()
    }

    public func track(_ eventName: String, properties: [String: Any]?) {
        guard isSessionInProgress else { return }

        pendoManager.track(eventName, properties: properties)
    }
}
