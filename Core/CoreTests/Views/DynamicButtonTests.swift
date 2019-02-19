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
    func testBackgroundColorName() {
        let view = DynamicButton()
        view.backgroundColorName = "not a color name"
        XCTAssertNil(view.backgroundColor)
        view.backgroundColorName = "electric"
        XCTAssertEqual(view.backgroundColor, .named(.electric))
    }

    func testIconName() {
        let view = DynamicButton()
        view.iconName = "not an icon name"
        XCTAssertNil(view.image(for: .normal))
        view.iconName = "instructureSolid"
        XCTAssertEqual(view.image(for: .normal), .icon(.instructure, .solid))
    }

    func testTextColorName() {
        let view = DynamicButton()
        let tinter = UIView() // tintColor gets adjusted, so apply same with this
        view.textColorName = "not a color name"
        tinter.tintColor = .named(.electric)
        XCTAssertEqual(view.tintColor, tinter.tintColor)
        view.textColorName = "ash"
        tinter.tintColor = .named(.ash)
        XCTAssertEqual(view.tintColor, tinter.tintColor)
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
