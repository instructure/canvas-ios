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

import XCTest
import UIKit
@testable import Core

class UserAgentTests: XCTestCase {
    func testProductNameForBundle() {
        XCTAssertEqual(UserAgent.default.productNameForBundle(Bundle.parentBundleID), "iosParent")
        XCTAssertEqual(UserAgent.default.productNameForBundle(Bundle.teacherBundleID), "iosTeacher")
        XCTAssertEqual(UserAgent.default.productNameForBundle(Bundle.studentBundleID), "iCanvas")
        XCTAssertEqual(UserAgent.default.productNameForBundle(nil), "iCanvas")
    }

    func testDescription() {
        XCTAssertEqual(UserAgent.default.description, "iCanvas/1.0 (1) \(UIDevice.current.model)/\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
        let systemVersion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
        XCTAssertEqual(UserAgent.safari.description, "Mozilla/5.0 (iPhone; CPU iPhone OS \(systemVersion) like Mac OS X)"
            + " AppleWebKit/603.1.23 (KHTML, like Gecko) Version/10.0 Mobile/14E5239e Safari/602.1")
    }
}
