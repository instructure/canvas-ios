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
import PSPDFKit
@testable import Core

class DocViewerPointAnnotationTests: XCTestCase {
    func testDraw() {
        let point = DocViewerPointAnnotation(image: nil)
        point.boundingBox = CGRect(x: -8.5, y: -12, width: 17, height: 24) // centered over origin
        point.color = nil // use default

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        point.draw(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let pixelData = image.cgImage?.dataProvider?.data!
        let data = CFDataGetBytePtr(pixelData)!

        let red = UInt(data[2]), green = UInt(data[1]), blue = UInt(data[0]), alpha = UInt(data[3])
        let num = (alpha << 24) + (red << 16) + (green << 8) + blue
        XCTAssertEqual("#\(String(num, radix: 16))".replacingOccurrences(of: "#ff", with: "#"), DocViewerAnnotationColor.blue.color.hexString)
    }
}
