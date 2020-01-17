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
@testable import Core
@testable import CoreUITests
@testable import TestsFoundation

class StudentUITestCase: CoreUITestCase {
    override var abstractTestClass: CoreUITestCase.Type { return StudentUITestCase.self }
    override var user: UITestUser? { return nil }

    func navBarColorHex() -> String? {
        let image = app.navigationBars.firstMatch.screenshot().image
        guard let pixelData = image.cgImage?.dataProvider?.data,
            let data = CFDataGetBytePtr(pixelData) else {
            return nil
        }
        // test bottom because of potential rounded corners at the top
        let bottom = Int(image.size.width) * Int(image.size.height) * 4
        let red = UInt(data[bottom + 0]), green = UInt(data[bottom + 1]), blue = UInt(data[bottom + 2]), alpha = UInt(data[bottom + 3])
        let num = (alpha << 24) + (red << 16) + (green << 8) + blue
        return "#\(String(num, radix: 16))".replacingOccurrences(of: "#ff", with: "#")
    }

}
