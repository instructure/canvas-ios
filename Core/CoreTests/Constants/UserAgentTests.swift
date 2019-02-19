//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
