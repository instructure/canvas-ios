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

class DynamicButtonTests: XCTestCase {
    func testTextColorName() {
        let view = DynamicButton()
        var prev = view.tintColor // tint adjusting means we can't directly compare the colors
        view.textColorName = "not a color name"
        XCTAssertNotEqual(view.tintColor, prev)
        prev = view.tintColor
        view.textColorName = "ash"
        XCTAssertNotEqual(view.tintColor, prev)
    }

    func testTextStyle() {
        let view = DynamicButton()
        view.textStyle = "not a real style"
        XCTAssertNotNil(view.titleLabel?.font)
        view.textStyle = "title"
        XCTAssertNotNil(view.titleLabel?.font)
        XCTAssertTrue(view.titleLabel!.adjustsFontForContentSizeCategory)
    }
}
