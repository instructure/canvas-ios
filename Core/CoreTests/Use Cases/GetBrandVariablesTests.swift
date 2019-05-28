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

import Foundation
import XCTest
import TestsFoundation
@testable import Core

class GetBrandVariablesTest: CoreTestCase {
    func testItUpdatesBrandVariables() {
        let prev = Brand.shared
        XCTAssertNoThrow(try GetBrandVariables().write(response: nil, urlResponse: nil, to: databaseClient))
        XCTAssertEqual(Brand.shared, prev)

        let brand = APIBrandVariables.make(primary: "#ffff00")
        XCTAssertNoThrow(try GetBrandVariables().write(response: brand, urlResponse: nil, to: databaseClient))
        XCTAssertEqual(Brand.shared.primary.hexString, "#ffff00")
    }
}
