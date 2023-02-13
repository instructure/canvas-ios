//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import SwiftUI
import WebKit

public class K5SubjectViewMasqueradedSession {
    /** The webview configuration to be used. In case of masquerading we can't use the default configuration because it will contain cookies with the original user's permissions. */
    public var config: WKWebViewConfiguration {
        guard isMasqueradingUser else { return .defaultConfiguration }
        let result = WKWebViewConfiguration()
        result.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        return result
    }
    public var handlesTabChangeEvents: Bool { isMasqueradingUser }
    public var sessionURL: AnyPublisher<URL?, Never> { masqueradedSessionURLSubject.eraseToAnyPublisher() }

    private let env: AppEnvironment
    private let masqueradedSessionURLSubject = PassthroughSubject<URL?, Never>()
    private var isMasqueradingUser: Bool { env.currentSession?.actAsUserID != nil }
    /** To speed up tab change we store already initialized masqueraded session URLs for each tab. */
    private var masqueradedSessionURLCacheByItemIndex: [Int: URL] = [:]
    private var masqueradedSessionRequest: APITask?

    public init(env: AppEnvironment) {
        self.env = env
    }

    public func tabChanged(toIndex: Int, toURL: URL) {
        if let cachedURL = masqueradedSessionURLCacheByItemIndex[toIndex] {
            masqueradedSessionURLSubject.send(cachedURL)
        } else {
            startMasqueradedSession(for: toURL, itemIndex: toIndex)
        }
    }

    private func startMasqueradedSession(for url: URL, itemIndex: Int) {
        masqueradedSessionRequest?.cancel()
        masqueradedSessionRequest = env.api.makeRequest(GetWebSessionRequest(to: url, path: "login/session_token")) { [weak self] response, _, _ in
            performUIUpdate {
                let safeURL = response?.session_url ?? url
                self?.masqueradedSessionURLSubject.send(safeURL)
                self?.masqueradedSessionURLCacheByItemIndex[itemIndex] = safeURL
                self?.masqueradedSessionRequest = nil
            }
        }
    }
}
