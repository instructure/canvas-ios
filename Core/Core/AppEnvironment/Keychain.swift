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

class Keychain {
    private let serviceName: String
    private let accessGroup: String?
    static let shared = Keychain()

    init(serviceName: String = Bundle.main.bundleIdentifier ?? "com.instructure.general-purpose-keychain", accessGroup: String? = nil) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }

    @discardableResult
    func setData(_ data: Data, for key: String) -> Bool {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
        ]

        if accessGroup?.isEmpty == false {
            query[kSecAttrAccessGroup] = accessGroup
        }

        //  try add
        var status: OSStatus = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            return true
        }
        // try to update
        else if status == errSecDuplicateItem {
            query[kSecValueData] = nil
            let updateQuery: [CFString: Any] = [kSecValueData: data]
            status = SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary)
            return status == errSecSuccess
        }

        return false
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
