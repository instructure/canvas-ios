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
import PSPDFKitUI
@testable import Core

class DocViewerConstantsTests: XCTestCase {
    func testColors() {
        for color in DocViewerAnnotationColor.allCases {
            XCTAssertNoThrow(color.color)
        }
        for color in DocViewerHighlightColor.allCases {
            XCTAssertNoThrow(color.color)
        }
    }

    func testBuilder() {
        let config = PDFConfiguration(builder: docViewerConfigurationBuilder)
        XCTAssertEqual(config.pageMode, .single)
        XCTAssertEqual(config.pageTransition, .scrollContinuous)
        XCTAssertEqual(config.scrollDirection, .vertical)
        XCTAssertEqual(config.naturalDrawingAnnotationEnabled, false) // MBL-13579
    }

    func testStyle() {
        stylePSPDFKit()
        XCTAssertEqual(SDK.shared.styleManager.lastUsedProperty(
           "color",
           forKey: Annotation.ToolVariantID(rawValue: Annotation.Tool.ink.rawValue)
        ) as? UIColor, DocViewerAnnotationColor.red.color)
        XCTAssertEqual(SDK.shared.styleManager.lastUsedProperty(
            "fillColor",
            forKey: Annotation.ToolVariantID(rawValue: Annotation.Tool.freeText.rawValue)
        ) as? UIColor, .clear)
        XCTAssertEqual(SDK.shared.styleManager.lastUsedProperty(
            "color",
            forKey: Annotation.ToolVariantID(rawValue: Annotation.Tool.freeText.rawValue)
        ) as? UIColor, .black)
        let textPresets = SDK.shared.styleManager.presets(forKey: Annotation.ToolVariantID(rawValue: Annotation.Tool.freeText.rawValue), type: .colorPreset) as? [ColorPreset]
        XCTAssertNotNil(textPresets)
        XCTAssertEqual(textPresets?.count, DocViewerAnnotationColor.allCases.count * 2)
        for annotationColor in DocViewerAnnotationColor.allCases {
            XCTAssertTrue(textPresets?.contains { $0.color == annotationColor.color && $0.fillColor?.hexString == UIColor.textLightest.variantForLightMode.hexString } == true)
            XCTAssertTrue(textPresets?.contains { $0.color == annotationColor.color && $0.fillColor == nil } == true)
        }
    }
}
