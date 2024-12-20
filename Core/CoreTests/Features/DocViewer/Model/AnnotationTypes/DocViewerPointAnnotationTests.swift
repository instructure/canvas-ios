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

import XCTest
import PSPDFKit
@testable import Core

class DocViewerPointAnnotationTests: XCTestCase {
    func testDraw() {
        let point = DocViewerPointAnnotation(image: nil)
        point.boundingBox = CGRect(x: -8.5, y: -12, width: 17, height: 24) // centered over origin
        point.color = nil // use default

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        point.draw(context: UIGraphicsGetCurrentContext()!, options: nil)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let pixelData = image.cgImage?.dataProvider?.data!
        let data = CFDataGetBytePtr(pixelData)!

        let red = UInt(data[2]), green = UInt(data[1]), blue = UInt(data[0]), alpha = UInt(data[3])
        let num = (alpha << 24) + (red << 16) + (green << 8) + blue
        XCTAssertEqual("#\(String(num, radix: 16))".replacingOccurrences(of: "#ff", with: "#"), DocViewerAnnotationColor.blue.color.hexString)
    }
}
