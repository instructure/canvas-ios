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

import Foundation
import Security
import Core

struct Pandata {
    static let tokenKeychainKey = "com.instructure.pandataToken"
    static let tokenKeychainService = Bundle.main.bundleIdentifier ?? Bundle.studentBundleID
}

class PageViewEventRequestManager {
    private let maxBatchCount = 300

    func sendEvents(handler: @escaping ErrorHandler) {
        retrievePandataEndpointInfo { [weak self] token in
            guard let self = self, let token = token else { return handler(nil) }

            let count = min(self.maxBatchCount, Persistency.instance.queueCount)
            guard count > 0 else { return handler(nil) }

            var backgroundTask = UIBackgroundTaskIdentifier.invalid
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "send pageview events") {
                backgroundTask = UIBackgroundTaskIdentifier.invalid
            }

            let events = Persistency.instance.batchOfEvents(count).map { $0.apiEvent(token) }

            AppEnvironment.shared.api.makeRequest(PostPandataEventsRequest(token: token, events: events)) { (response, _, error) in
                guard response?.lowercased() == "\"ok\"", error == nil else {
                    handler(error)
                    UIApplication.shared.endBackgroundTask(backgroundTask)
                    return
                }
                Persistency.instance.dequeue(count, handler: {
                    handler(nil)
                    UIApplication.shared.endBackgroundTask(backgroundTask)
                })
            }
        }
    }

    func cleanup() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: Pandata.tokenKeychainService,
            kSecAttrAccount: Pandata.tokenKeychainKey,
        ]
        _ = SecItemDelete(query as CFDictionary)
    }

    private func storePandataEndpointInfo(_ token: APIPandataEventsToken) {
        guard let data = try? JSONEncoder().encode(token) else { return }
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: Pandata.tokenKeychainService,
            kSecAttrAccount: Pandata.tokenKeychainKey,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
        ]
        _ = SecItemAdd(query as CFDictionary, nil)
    }

    private func retrievePandataEndpointInfo(handler: @escaping (APIPandataEventsToken?) -> Void) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: Pandata.tokenKeychainService,
            kSecAttrAccount: Pandata.tokenKeychainKey,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &result) == noErr,
            let data = result as? Data,
            let token = try? JSONDecoder().decode(APIPandataEventsToken.self, from: data),
            Date(timeIntervalSince1970: token.expires_at / 1000) >= Date() {
            return handler(token)
        }

        var backgroundTask = UIBackgroundTaskIdentifier.invalid
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "fetch pandata token") {
            backgroundTask = UIBackgroundTaskIdentifier.invalid
        }
        AppEnvironment.shared.api.makeRequest(PostPandataEventsTokenRequest()) { [weak self] (token, _, _) in
            if let token = token {
                self?.storePandataEndpointInfo(token)
            }
            handler(token)
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
    }
}
