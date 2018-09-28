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

class UIImageIcon: XCTestCase {
    func testIconNamed() {
        XCTAssertEqual(UIImage.icon(.alerts), UIImage(named: "alerts", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIImage.icon(.back), UIImage(named: "back", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIImage.icon(.calendarMonth), UIImage(named: "calendarMonth", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIImage.icon(.dashboard), UIImage(named: "dashboard", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIImage.icon(.email), UIImage(named: "email", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIImage.icon(.more), UIImage(named: "more", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIImage.icon(.todo), UIImage(named: "todo", in: .core, compatibleWith: nil))
    }
}
