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

class DynamicLabelTests: XCTestCase {
    func testTextColorName() {
        let view = DynamicLabel(frame: .zero)
        view.textColorName = "not a color name"
        XCTAssertEqual(view.textColor, UIColor.named(.textDarkest))
        view.textColorName = "electric"
        XCTAssertEqual(view.textColor, UIColor.named(.electric))
    }

    func testTextStyle() {
        let view = DynamicLabel(frame: .zero)
        view.textStyle = "not a real style"
        XCTAssertNotNil(view.font)
        view.textStyle = "title"
        XCTAssertNotNil(view.font)
        XCTAssertTrue(view.adjustsFontForContentSizeCategory)
    }
}
