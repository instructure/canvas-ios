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

import XCTest
@testable import Core

class GeneralPurposeKeychainTests: XCTestCase {

    let serviceName = "com.test"
    let accessGroup = "com.instructure.test"
    var keychain: GeneralPurposeKeychain!
    override func setUp() {
        super.setUp()
        keychain = GeneralPurposeKeychain(serviceName: serviceName, accessGroup: nil)
    }

    func testGetData() {
        let key = "foo"
        var str = "test"
        var data = str.data(using: .utf8)!
        keychain.setData(data, for: key)

        let newInstance = GeneralPurposeKeychain(serviceName: serviceName, accessGroup: nil)
        var strData = newInstance.data(for: key)!
        var result = String(data: strData, encoding: .utf8)
        XCTAssertEqual(result, str)

        str = "new value"
        data = str.data(using: .utf8)!
        keychain.setData(data, for: key)

        strData = newInstance.data(for: key)!
        result = String(data: strData, encoding: .utf8)
        XCTAssertEqual(result, str)
    }

    func testGetDictionary() {
        let key = "myDictionary"
        let date = Date(fromISOString: "2019-06-25T06:00:00Z")!
        let dict: [String: Any] = ["foo": "bar", "date": date]
        keychain.setItem(dict, for: key)

        let newInstance = GeneralPurposeKeychain(serviceName: serviceName, accessGroup: nil)
        if let result: [String: Any] = newInstance.item(for: key) as? [String: Any] {
            XCTAssertEqual(result["foo"] as! String, dict["foo"] as! String)
            XCTAssertEqual(result["date"] as! Date, dict["date"] as! Date)
        } else {
            XCTFail("invalid format, expected dictionary")
        }
    }

    func testRemoveItem() {
        let key = "foo"
        let str = "test"

        keychain.setItem(str, for: key)

        let value = keychain.item(for: key) as? String
        XCTAssertEqual(str, value)

        let result = keychain.removeItem(for: key)
        XCTAssertTrue(result)

        let shouldBeNil = keychain.item(for: key) as? String
        XCTAssertNil(shouldBeNil)
    }

    func testSharedInstance() {
        let key = "foo"
        let str = "test"

        GeneralPurposeKeychain.shared.setItem(str, for: key)

        let value = GeneralPurposeKeychain.shared.item(for: key) as? String
        XCTAssertEqual(str, value)
    }
}
