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
@testable import Core

class UIColorExtensionsTests: XCTestCase {
    func testHexString() {
        XCTAssertEqual(UIColor(hexString: "#12345678")?.hexString, "#12345678")
        XCTAssertNil(UIColor(hexString: "#1234567"))
        XCTAssertEqual(UIColor(hexString: "#aBCdef")?.hexString, "#abcdef")
        XCTAssertNil(UIColor(hexString: "#abcde"))
        XCTAssertEqual(UIColor(hexString: "#89ab")?.hexString, "#8899aabb")
        XCTAssertEqual(UIColor(hexString: "#aBc")?.hexString, "#aabbcc")
        XCTAssertNil(UIColor(hexString: "#ab"))
        XCTAssertNil(UIColor(hexString: "#1"))
        XCTAssertNil(UIColor(hexString: "123456"))
        XCTAssertNil(UIColor(hexString: "#nothex"))
    }

    func testNamed() {
        for name in UIColor.Name.allCases {
            XCTAssertNotNil(UIColor.named(name, inHighContrast: false))
            XCTAssertNotNil(UIColor.named(name, inHighContrast: true))
        }
    }

    func testLuminance() {
        XCTAssertEqual(UIColor.white.luminance, 1.0)
        XCTAssertEqual(UIColor.black.luminance, 0.0)
        XCTAssertEqual(UIColor.blue.luminance, 0.0722)
    }

    func testContrast() {
        XCTAssertEqual(UIColor.white.contrast(against: .black), 21.0)
        XCTAssertEqual(UIColor.black.contrast(against: .white), 21.0)
        XCTAssertEqual(UIColor.black.contrast(against: .blue), 2.44, accuracy: 0.01)
        XCTAssertEqual(UIColor.blue.contrast(against: .white), 8.59, accuracy: 0.01)
    }

    func testEnsureContrast() {
        XCTAssertEqual(UIColor.black.ensureContrast(against: .blue, inHighContrast: false).hexString, "#000000")
        XCTAssertEqual(UIColor.black.ensureContrast(against: .blue, inHighContrast: true).hexString, "#bcbcbc")
        XCTAssertEqual(UIColor.blue.ensureContrast(against: .black, inHighContrast: true).hexString, "#5f5fff")
        XCTAssertEqual(UIColor.yellow.ensureContrast(against: .white, inHighContrast: true).hexString, "#7a7a00")
    }

    func testCurrentLogoColor() {
        XCTAssertEqual(UIColor.currentLogoColor(for: Bundle.parentBundleID), UIColor.parentLogoColor)
        XCTAssertEqual(UIColor.currentLogoColor(for: Bundle.studentBundleID), UIColor.studentLogoColor)
        XCTAssertEqual(UIColor.currentLogoColor(for: Bundle.teacherBundleID), UIColor.teacherLogoColor)
        XCTAssertEqual(UIColor.currentLogoColor(), UIColor.studentLogoColor)
    }
}
