//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import UIKit
import XCTest
@testable import Core

class UIButtonExtensionTests: XCTestCase {

    func testButtonBadge() {
        let b = DynamicButton()
        b.iconName = "hamburgerSolid"

        XCTAssertNoThrow(  b.addBadge(number: 3, color: .red) )
        let textLayer: CATextLayer? = b.layer.sublayers?.first?.sublayers?.filter { $0 is CATextLayer }.first as? CATextLayer
        let value: String? = textLayer?.string as? String
        XCTAssertEqual(value, "3")
        let shape = b.layer.sublayers?.first as? CAShapeLayer
        XCTAssertEqual(shape?.fillColor, UIColor.white.cgColor)
        XCTAssertEqual(shape?.strokeColor, UIColor.red.cgColor)
    }
}
