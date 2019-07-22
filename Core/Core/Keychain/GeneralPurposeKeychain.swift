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

class GeneralPurposeKeychain {

    private (set) public var serviceName: String
    private (set) public var accessGroup: String?
    static let shared = GeneralPurposeKeychain()

    private static let defaultServiceName: String = {
        return Bundle.main.bundleIdentifier ?? "com.instructure.general-purpose-keychain"
    }()

    private convenience init() {
        self.init(serviceName: type(of: self).defaultServiceName)
    }

    init(serviceName: String, accessGroup: String? = nil) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }

    @discardableResult
    func setItem(_ value: Any, for key: String) -> Bool {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
            return setData(data, for: key)
        } catch {
            return false
        }
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

    func data(for key: String) -> Data? {
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

    func item(for key: String) -> Any? {
        guard let data: Data = data(for: key) else {
            return nil
        }

        return NSKeyedUnarchiver.unarchiveObject(with: data) as? NSCoding
    }

    @discardableResult
    func removeItem(for key: String) -> Bool {
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
