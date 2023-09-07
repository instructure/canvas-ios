//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public class Keychain {
    private let serviceName: String
    private let accessGroup: String?
    public static let app = Keychain(serviceName: "com.instructure.shared-credentials", accessGroup: Bundle.main.appGroupID())
    public static var shared = Keychain(serviceName: "com.instructure.shared-credentials", accessGroup: "group.instructure.shared.2u")

    init(serviceName: String = Bundle.main.bundleIdentifier ?? "com.instructure.general-purpose-keychain.2u", accessGroup: String? = nil) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }

    @discardableResult
    func setData(_ data: Data, for key: String) -> Bool {
        // Only query with class, service, and account
        // https://forums.developer.apple.com/message/259602#259602
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key,
        ]
        if accessGroup?.isEmpty == false {
            query[kSecAttrAccessGroup] = accessGroup
        }
        let exists = SecItemCopyMatching(query as CFDictionary, nil) == noErr
        var status: OSStatus?
        if exists {
            status = SecItemUpdate(query as CFDictionary, [kSecValueData: data] as CFDictionary)
        } else {
            query[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
            query[kSecValueData] = data
            status = SecItemAdd(query as CFDictionary, nil)
        }
        assert(status == errSecSuccess)
        return status == errSecSuccess
    }

    @discardableResult
    func setJSON<T: Encodable>(_ value: T, for key: String) throws -> Bool {
        return setData(try JSONEncoder().encode(value), for: key)
    }

    func getData(for key: String) -> Data? {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne,
        ]

        if accessGroup?.isEmpty == false {
            query[kSecAttrAccessGroup] = accessGroup
        }

        var result: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &result) == noErr {
            return result as? Data
        }
        return nil
    }

    func getJSON<T: Decodable>(for key: String) -> T? {
        guard let data = getData(for: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    @discardableResult
    func removeData(for key: String) -> Bool {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key,
        ]

        if accessGroup?.isEmpty == false {
            query[kSecAttrAccessGroup] = accessGroup
        }

        return SecItemDelete(query as CFDictionary) == noErr
    }
}
