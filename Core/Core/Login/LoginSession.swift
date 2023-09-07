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
    public let accessToken: String?
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
    public let clientID: String?
    public let clientSecret: String?

    /** Returns the acted user's ID. If the session isn't masquaraded this property returns nil. */
    public var actAsUserID: String? {
        return masquerader == nil ? nil : userID
    }

    public var originalUserID: String? {
        return masquerader?.lastPathComponent
    }

    public var originalBaseURL: URL? {
        return masquerader?.host.flatMap { URL(string: "https://\($0)") }
    }

    public var isFakeStudent: Bool {
        masquerader?.path.split(separator: "/").first == "fake-students"
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

    public var clearDomain: String {
        baseURL.absoluteString
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
    }

    public init(
        accessToken: String? = nil,
        baseURL: URL,
        expiresAt: Date? = nil,
        lastUsedAt: Date = Date(),
        locale: String? = nil,
        masquerader: URL? = nil,
        refreshToken: String? = nil,
        userAvatarURL: URL? = nil,
        userID: String,
        userName: String,
        userEmail: String? = nil,
        clientID: String? = nil,
        clientSecret: String? = nil,
        isFakeStudent: Bool = false
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
        self.clientID = clientID
        self.clientSecret = clientSecret
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
            lastUsedAt: Clock.now,
            locale: locale,
            masquerader: masquerader,
            refreshToken: refreshToken,
            userAvatarURL: userAvatarURL,
            userID: userID,
            userName: userName,
            userEmail: userEmail,
            clientID: clientID,
            clientSecret: clientSecret
        )
    }

    public func refresh(accessToken: String, expiresAt: Date?) -> LoginSession {
        return LoginSession(
            accessToken: accessToken,
            baseURL: baseURL,
            expiresAt: expiresAt,
            lastUsedAt: lastUsedAt,
            locale: locale,
            masquerader: masquerader,
            refreshToken: refreshToken,
            userAvatarURL: userAvatarURL,
            userID: userID,
            userName: userName,
            userEmail: userEmail,
            clientID: clientID,
            clientSecret: clientSecret
        )
    }

    // MARK: Persistence into keychain

    public enum Key: String, CaseIterable {
        case users = "CanvasUsers"
        case fakeStudents = "FakeStudents"
    }

    private static func getSessions(in keychain: Keychain = .app, forKey key: Key = .users) -> Set<LoginSession> {
        return keychain.getJSON(for: key.rawValue) ?? []
    }

    private static func setSessions(_ sessions: Set<LoginSession>, in keychain: Keychain = .app, forKey key: Key = .users) {
        _ = try? keychain.setJSON(sessions, for: key.rawValue)
    }

    public static var sessions: Set<LoginSession> {
        get { return getSessions() }
        set { setSessions(newValue) }
    }

    public static var mostRecent: LoginSession? {
        return mostRecent(in: .app, forKey: .users)
    }

    public static func mostRecent(in keychain: Keychain, forKey key: Key) -> LoginSession? {
        return getSessions(in: keychain).reduce(nil) { (latest: LoginSession?, session: LoginSession) -> LoginSession? in
            if let latest = latest, latest.lastUsedAt > session.lastUsedAt {
                return latest
            }
            return session
        }
    }

    public static func add(_ session: LoginSession, to keychain: Keychain = .app, forKey key: Key = .users) {
        var sessions = getSessions(in: keychain, forKey: key)
        sessions.remove(session)
        sessions.insert(session)
        setSessions(sessions, in: keychain)
    }

    public static func remove(_ session: LoginSession, from keychain: Keychain = .app, forKey key: Key = .users) {
        var sessions = getSessions(in: keychain, forKey: key)
        sessions.remove(session)
        setSessions(sessions, in: keychain)
    }

    public static func clearAll(in keychain: Keychain = .app) {
        for key in Key.allCases {
            keychain.removeData(for: key.rawValue)
        }
    }
}
