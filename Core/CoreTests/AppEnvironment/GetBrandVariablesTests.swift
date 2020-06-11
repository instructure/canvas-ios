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

import Foundation
import XCTest
import TestsFoundation
@testable import Core

class GetBrandVariablesTest: CoreTestCase {
    func testItUpdatesBrandVariables() {
        let response = HTTPURLResponse(url: URL(string: "https://canvas.instructure.com/brand_variables")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let prev = Brand.shared
        GetBrandVariables().write(response: nil, urlResponse: response, to: databaseClient)
        XCTAssertEqual(Brand.shared, prev)

        let brand = APIBrandVariables.make(primary: "#ffff00")
        GetBrandVariables().write(response: brand, urlResponse: response, to: databaseClient)
        XCTAssertEqual(Brand.shared.primary.hexString, "#ffff00")
    }
}
