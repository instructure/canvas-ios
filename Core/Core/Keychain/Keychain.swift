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
import Security

public struct KeychainConfig {
    public let service: String
    public let accessGroup: String?

    public init(service: String = "com.instructure.shared-credentials", accessGroup: String? = Bundle.main.appGroupID()) {
        self.service = service
        self.accessGroup = accessGroup
    }
}

public struct KeychainEntry: Codable, Hashable {
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

    public var actAsUserID: String? {
        return masquerader == nil ? nil : userID
    }

    public var masqueradingUserID: String? {
        return masquerader?.lastPathComponent
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
        userName: String
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
    }

    // Only keep 1 entry per account user
    public func hash(into hasher: inout Hasher) {
        hasher.combine(baseURL)
        hasher.combine(masquerader)
        hasher.combine(userID)
    }

    public static func == (lhs: KeychainEntry, rhs: KeychainEntry) -> Bool {
        return (
            lhs.baseURL == rhs.baseURL &&
            lhs.masquerader == rhs.masquerader &&
            lhs.userID == rhs.userID
        )
    }

    public func bumpLastUsedAt() -> KeychainEntry {
        return KeychainEntry(
            accessToken: accessToken,
            baseURL: baseURL,
            expiresAt: expiresAt,
            lastUsedAt: Date(),
            locale: locale,
            masquerader: masquerader,
            refreshToken: refreshToken,
            userAvatarURL: userAvatarURL,
            userID: userID,
            userName: userName
        )
    }
}

/// Keychain is a thin layer over the iOS keychain
/// This is used for storing user login information
/// We don't store anything else in the keychain, so this class is specific to that
public class Keychain {
    public static var config = KeychainConfig()

    public static let key = "CanvasUsers"

    public static var currentSession: KeychainEntry?

    public static var mostRecentSession: KeychainEntry? {
        return entries.reduce(nil) { (latest: KeychainEntry?, entry: KeychainEntry) -> KeychainEntry? in
            if let latest = latest, latest.lastUsedAt > entry.lastUsedAt {
                return latest
            }
            return entry
        }
    }

    public static var entries: Set<KeychainEntry> {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: config.service,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        if let group = config.accessGroup {
            query[kSecAttrAccessGroup] = group
        }

        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == noErr,
            let data = result as? Data else { return [] }
        return decode(data) ?? []
    }

    @discardableResult
    public static func addEntry(_ entry: KeychainEntry) -> Bool {
        var current = entries
        // replace existing entry for the user
        current.remove(entry)
        current.insert(entry)
        return update(current)
    }

    @discardableResult
    public static func removeEntry(_ entry: KeychainEntry) -> Bool {
        var current = entries
        current.remove(entry)
        return update(current)
    }

    @discardableResult
    private static func update(_ value: Set<KeychainEntry>) -> Bool {
        guard let data = encode(value) else { return false }
        clearEntries()

        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: config.service,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
        ]
        if let group = config.accessGroup {
            query[kSecAttrAccessGroup] = group
        }

        return SecItemAdd(query as CFDictionary, nil) == noErr
    }

    @discardableResult
    public static func clearEntries() -> Bool {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: config.service,
            kSecAttrAccount: key,
        ]
        if let group = config.accessGroup {
            query[kSecAttrAccessGroup] = group
        }

        return SecItemDelete(query as CFDictionary) == noErr
    }

    private static func encode(_ set: Set<KeychainEntry>) -> Data? {
        do {
            return try JSONEncoder().encode(set)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    private static func decode(_ data: Data) -> Set<KeychainEntry>? {
        do {
            return try JSONDecoder().decode(Set<KeychainEntry>.self, from: data)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
