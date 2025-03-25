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

class KeychainTests: XCTestCase {

    let serviceName = "com.test"
    let accessGroup = "com.instructure.test"
    var keychain: Keychain!
    override func setUp() {
        super.setUp()
        keychain = Keychain(serviceName: serviceName, accessGroup: nil)
    }

    func testGetData() {
        let key = "foo"
        var str = "test"
        var data = str.data(using: .utf8)!
        keychain.setData(data, for: key)

        let newInstance = Keychain(serviceName: serviceName, accessGroup: nil)
        var strData = newInstance.getData(for: key)!
        var result = String(data: strData, encoding: .utf8)
        XCTAssertEqual(result, str)

        str = "new value"
        data = str.data(using: .utf8)!
        keychain.setData(data, for: key)

        strData = newInstance.getData(for: key)!
        result = String(data: strData, encoding: .utf8)
        XCTAssertEqual(result, str)
    }

    func testGetDictionary() {
        let key = "myDictionary"
        let date = Date(fromISOString: "2019-06-25T06:00:00Z")!
        let dict: [String: Any] = ["foo": "bar", "date": date]
        let data = try! NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false)
        keychain.setData(data, for: key)

        let newInstance = Keychain(serviceName: serviceName, accessGroup: nil)
        let allowedClasses = [NSDictionary.self, NSString.self, NSDate.self]
        if let data = newInstance.getData(for: key), let result =  try! NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClasses, from: data) as? [String: Any] {
            XCTAssertEqual(result["foo"] as! String, dict["foo"] as! String)
            XCTAssertEqual(result["date"] as! Date, dict["date"] as! Date)
        } else {
            XCTFail("invalid format, expected dictionary")
        }
    }

    func testRemoveData() {
        let key = "foo"
        let str = "test"

        keychain.setData(str.data(using: .utf8)!, for: key)

        if let data = keychain.getData(for: key) {
            let value = String(data: data, encoding: .utf8)
            XCTAssertEqual(str, value)
        } else {
            XCTFail()
        }

        let result = keychain.removeData(for: key)
        XCTAssertTrue(result)

        let shouldBeNil = keychain.getData(for: key)
        XCTAssertNil(shouldBeNil)
    }
}
