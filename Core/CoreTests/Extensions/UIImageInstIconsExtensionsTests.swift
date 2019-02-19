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

class UIImageInstIconsExtensionsTests: XCTestCase {
    func testIconNamed() {
        for name in UIImage.InstIconName.allCases {
            XCTAssertEqual(UIImage.icon(name, .line), UIImage(named: "\(name)Line", in: .core, compatibleWith: nil))
            XCTAssertEqual(UIImage.icon(name, .solid), UIImage(named: "\(name)Solid", in: .core, compatibleWith: nil))
        }
    }
}
