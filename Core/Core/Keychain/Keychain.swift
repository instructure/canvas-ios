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

//  Keychain is a thin layer over the iOS keychain
//  This is used for storing user login information
//  We don't store anything else in the keychain, so this class is specific to that
//
//  I used the following as a reference on how to do this in swift:
//  https://github.com/evgenyneu/keychain-swift/blob/master/Distrib/KeychainSwiftDistrib.swift

import Foundation
import Security

let key = "CanvasUsers"

// I think that the student app should probably supply these?
let serviceID = "com.instructure.shared-credentials"
let accessGroup = "8MKNFMCD9M.com.instructure.shared-credentials"

public struct KeychainConfig {
    let service: String
    let accessGroup: String?
}

public struct KeychainEntry: Codable, Hashable {
    let token: String
    let baseURL: String
}

open class Keychain {

    // If not config is set, will use the default access group for the canvas apps
    open static var config: KeychainConfig?

    open static var entries: Set<KeychainEntry> {
        guard let data = getData() else { return [] }
        do {
            let entries = try JSONDecoder().decode(Set<KeychainEntry>.self, from: data)
            return entries
        } catch _ {
            return []
        }
    }

    @discardableResult
    open static func addEntry(_ entry: KeychainEntry) -> Bool {
        var current = entries
        current.insert(entry)
        return updateEntries(current)
    }

    @discardableResult
    open static func removeEntry(_ entry: KeychainEntry) -> Bool {
        var current = entries
        current.remove(entry)
        return updateEntries(current)
    }

    @discardableResult
    open static func clearEntries() -> Bool {
        return delete()
    }

    private static var serviceID: String {
        if let c = config { return c.service }
        guard let bundleID = Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String else {
            // I highly, highly doubt that this will ever hit this case ;)
            return "unknown-service"
        }

        return bundleID
    }

    private static func updateEntries(_ entries: Set<KeychainEntry>) -> Bool {
        do {
            let data = try JSONEncoder().encode(entries)
            return set(data)
        } catch let e {
            print(e)
            return false
        }
    }

    @discardableResult
    private static func set(_ value: Data) -> Bool {

        delete()

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceID,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        if let group = config?.accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }

        return SecItemAdd(query as CFDictionary, nil) == noErr
    }

    @discardableResult
    private static func delete() -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceID,
            kSecAttrAccount as String: key,
        ]

        if let group = config?.accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }

        return SecItemDelete(query as CFDictionary) == noErr
    }

    private static func getData() -> Data? {

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceID,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        if let group = config?.accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }

        var result: AnyObject?

        let resultCode = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        if resultCode == noErr { return result as? Data }

        return nil
    }
}
