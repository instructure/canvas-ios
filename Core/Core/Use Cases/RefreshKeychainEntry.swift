//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public class RefreshKeychainEntry: OperationSet {
    let entry: KeychainEntry
    let request: GetUserRequest
    let session: URLSession
    static let internalQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    lazy var fetch: APIOperation = {
        return APIOperation(api: URLSessionAPI(accessToken: entry.accessToken, baseURL: entry.baseURL, urlSession: session), request: request)
    }()

    public init(_ entry: KeychainEntry, session: URLSession = URLSession.shared) {
        self.entry = entry
        self.request = GetUserRequest(userID: entry.userID)
        self.session = session
        super.init()
        addSequence([
            fetch,
            BlockOperation { [weak self] in
                // Serialize saves to prevent klobbering each other.
                RefreshKeychainEntry.internalQueue.addOperation {
                    self?.save(self?.fetch.response)
                }
                RefreshKeychainEntry.internalQueue.waitUntilAllOperationsAreFinished()
            },
        ])
    }

    func save(_ response: APIUser?) {
        guard let response = response else { return }
        let refreshed = KeychainEntry(
            accessToken: entry.accessToken,
            baseURL: entry.baseURL,
            expiresAt: entry.expiresAt,
            lastUsedAt: entry.lastUsedAt,
            locale: response.locale ?? response.effective_locale,
            masquerader: entry.masquerader,
            refreshToken: entry.refreshToken,
            userAvatarURL: response.avatar_url,
            userID: entry.userID,
            userName: response.name
        )
        if Keychain.entries.contains(entry) {
            Keychain.addEntry(refreshed)
        }
        if Keychain.currentSession == entry {
            Keychain.currentSession = refreshed
        }
    }
}
