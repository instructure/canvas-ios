//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import UIKit
import Security

struct Pandata {
    static let tokenKeychainKey = "com.instructure.pandataToken"
    static let tokenKeychainService = Bundle.main.bundleIdentifier ?? Bundle.studentBundleID
}

class PageViewEventRequestManager {
    private let maxBatchCount = 300
    private let persistence: Persistency
    private let env: AppEnvironment
    private let keychain = Keychain(serviceName: Pandata.tokenKeychainService)
    var backgroundAppHelper: AppBackgroundHelperProtocol?

    init(persistence: Persistency = Persistency.instance, env: AppEnvironment = AppEnvironment.shared) {
        self.persistence = persistence
        self.env = env
    }

    func sendEvents(handler: @escaping ErrorHandler) {
        retrievePandataEndpointInfo { [weak self] token in
            guard let self = self,
                  let token = token,
                  let userID = AppEnvironment.shared.currentSession?.userID
            else { return handler(nil) }

            let count = min(self.maxBatchCount, self.persistence.queueCount(for: userID))
            guard count > 0 else { return handler(nil) }

            let taskName = "send pageview events"
            self.backgroundAppHelper?.startBackgroundTask(taskName: taskName)

            let events = self.persistence.batchOfEvents(count, userID: userID)?.map { $0.apiEvent(token) } ?? []

            self.env.api.makeRequest(PostPandataEventsRequest(token: token, events: events)) { (response, _, error) in
                guard response?.lowercased() == "\"ok\"", error == nil else {
                    handler(error)
                    self.backgroundAppHelper?.endBackgroundTask(taskName: taskName)
                    return
                }
                self.persistence.dequeue(count, userID: userID, handler: {
                    handler(nil)
                    self.backgroundAppHelper?.endBackgroundTask(taskName: taskName)
                })
            }
        }
    }

    func cleanup() {
        keychain.removeData(for: Pandata.tokenKeychainKey)
    }

    private func storePandataEndpointInfo(_ token: APIPandataEventsToken) {
        _ = try? keychain.setJSON(token, for: Pandata.tokenKeychainKey)
    }

    private func retrievePandataEndpointInfo(handler: @escaping (APIPandataEventsToken?) -> Void) {
        if let token: APIPandataEventsToken = keychain.getJSON(for: Pandata.tokenKeychainKey),
            Date(timeIntervalSince1970: token.expires_at / 1000) >= Date() {
            return handler(token)
        }

        let taskName = "fetch pandata token"
        self.backgroundAppHelper?.startBackgroundTask(taskName: taskName)

        env.api.makeRequest(PostPandataEventsTokenRequest()) { [weak self] (token, _, _) in
            if let token = token {
                self?.storePandataEndpointInfo(token)
            }
            handler(token)
            self?.backgroundAppHelper?.endBackgroundTask(taskName: taskName)
        }
    }
}
