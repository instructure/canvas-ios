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

public struct LoginSession: Codable, Hashable {
    public let accessToken: String
    public let baseURL: URL
    public let expiresAt: Date?
    public let lastUsedAt: Date
    public let locale: String?
    public let masquerader: URL?
    public let refreshToken: String?
    public let userAvatarURL: URL?
    public let userID: String
    public let userName: String
    public let userEmail: String?

    public var actAsUserID: String? {
        return masquerader == nil ? nil : userID
    }

    public var originalUserID: String? {
        return masquerader?.lastPathComponent
    }

    public var originalBaseURL: URL? {
        return masquerader?.host.flatMap { URL(string: "https://\($0)") }
    }

    public var uniqueID: String {
        return [
            baseURL.host,
            originalBaseURL?.host,
            userID,
            originalUserID,
        ]
        .compactMap { $0 }
        .joined(separator: "-")
    }

    public init(
        accessToken: String,
        baseURL: URL,
        expiresAt: Date?,
        lastUsedAt: Date = Date(),
        locale: String?,
        masquerader: URL? = nil,
        refreshToken: String?,
        userAvatarURL: URL? = nil,
        userID: String,
        userName: String,
        userEmail: String? = nil
    ) {
        self.accessToken = accessToken
        // remove trailing slash
        var components = URLComponents.parse(baseURL)
        components.path = ""
        self.baseURL = components.url ?? baseURL
        self.expiresAt = expiresAt
        self.lastUsedAt = lastUsedAt
        self.locale = locale
        self.masquerader = masquerader
        self.refreshToken = refreshToken
        self.userAvatarURL = userAvatarURL
        self.userID = userID
        self.userName = userName
        self.userEmail = userEmail
    }

    // Only keep 1 entry per account user
    public func hash(into hasher: inout Hasher) {
        hasher.combine(baseURL)
        hasher.combine(masquerader)
        hasher.combine(userID)
    }

    public static func == (lhs: LoginSession, rhs: LoginSession) -> Bool {
        return (
            lhs.baseURL == rhs.baseURL &&
            lhs.masquerader == rhs.masquerader &&
            lhs.userID == rhs.userID
        )
    }

    public func bumpLastUsedAt() -> LoginSession {
        return LoginSession(
            accessToken: accessToken,
            baseURL: baseURL,
            expiresAt: expiresAt,
            lastUsedAt: Date(),
            locale: locale,
            masquerader: masquerader,
            refreshToken: refreshToken,
            userAvatarURL: userAvatarURL,
            userID: userID,
            userName: userName,
            userEmail: userEmail
        )
    }

    // MARK: Persistence into keychain

    private static let key = "CanvasUsers"
    private static let keychain = Keychain(serviceName: "com.instructure.shared-credentials", accessGroup: Bundle.main.appGroupID())

    public static var sessions: Set<LoginSession> {
        get { return keychain.getJSON(for: key) ?? [] }
        set { _ = try? keychain.setJSON(newValue, for: key) }
    }

    public static var mostRecent: LoginSession? {
        return sessions.reduce(nil) { (latest: LoginSession?, session: LoginSession) -> LoginSession? in
            if let latest = latest, latest.lastUsedAt > session.lastUsedAt {
                return latest
            }
            return session
        }
    }

    public static func add(_ session: LoginSession) {
        var sessions = self.sessions
        sessions.remove(session)
        sessions.insert(session)
        self.sessions = sessions
    }

    public static func remove(_ session: LoginSession) {
        var sessions = self.sessions
        sessions.remove(session)
        self.sessions = sessions
    }

    public static func clearAll() {
        keychain.removeData(for: key)
    }
}
