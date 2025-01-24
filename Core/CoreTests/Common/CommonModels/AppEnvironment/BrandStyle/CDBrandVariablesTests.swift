//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@testable import Core
import XCTest
import SwiftUI

class CDBrandVariablesTests: CoreTestCase {

    func testSavesRawDataAndLoadsConvertedData() {
        let brandVariables = APIBrandVariables.make(button_primary_bgd: "test")
        let image = UIImage.addImageLine
        let imageData = image.pngData()!

        let testee = CDBrandVariables.save(brandVariables,
                                           headerImageData: imageData,
                                           in: databaseClient)
        XCTAssertNotEqual(testee.headerImage, nil)
        XCTAssertEqual(testee.brandVariables, brandVariables)
    }

    func testAppliesBrandTheme() {
        let brandVariables = APIBrandVariables.make(primary: "#FF0000")
        let testee = CDBrandVariables.save(
            brandVariables,
            headerImageData: UIImage.addImageLine.pngData(),
            in: databaseClient
        )
        let defaultImage = UIImage(named: "defaultHeaderImage", in: .core, compatibleWith: nil)
        XCTAssertEqual(Brand.shared.primary.hexString, UIColor.textInfo.hexString)
        XCTAssertEqual(Brand.shared.headerImage, defaultImage)

        // WHEN
        testee.applyBrandTheme()

        // THEN
        XCTAssertEqual(Brand.shared.primary.hexString, "#ff0000")
        XCTAssertNotEqual(Brand.shared.headerImage, defaultImage)
    }
}
