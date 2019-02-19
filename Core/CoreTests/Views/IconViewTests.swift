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

class IconViewTests: XCTestCase {
    func testIconName() {
        let view = IconView()
        view.iconName = "not an icon name"
        XCTAssertNil(view.image)
        view.iconName = "instructureSolid"
        XCTAssertEqual(view.image, .icon(.instructure, .solid))
    }

    func testIconColorName() {
        let view = IconView()
        let tinter = UIView() // tintColor gets adjusted, so apply same with this
        view.iconColorName = "not a color name"
        tinter.tintColor = .named(.electric)
        XCTAssertEqual(view.tintColor, tinter.tintColor)
        view.iconColorName = "primary"
        tinter.tintColor = Brand.shared.primary
        XCTAssertEqual(view.tintColor, tinter.tintColor)
    }
}
