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
        let config = PSPDFConfiguration(builder: docViewerConfigurationBuilder)
        XCTAssertEqual(config.pageMode, .single)
        XCTAssertEqual(config.pageTransition, .scrollContinuous)
        XCTAssertEqual(config.scrollDirection, .vertical)
    }

    func testStyle() {
        stylePSPDFKit()
        XCTAssertEqual(PSPDFKit.sharedInstance.styleManager.lastUsedProperty(
           "color",
           forKey: AnnotationStateVariantID(rawValue: AnnotationString.ink.rawValue)
        ) as? UIColor, DocViewerAnnotationColor.red.color)
        XCTAssertEqual(PSPDFKit.sharedInstance.styleManager.lastUsedProperty(
            "fillColor",
            forKey: AnnotationStateVariantID(rawValue: AnnotationString.freeText.rawValue)
        ) as? UIColor, .clear)
        XCTAssertEqual(PSPDFKit.sharedInstance.styleManager.lastUsedProperty(
            "color",
            forKey: AnnotationStateVariantID(rawValue: AnnotationString.freeText.rawValue)
        ) as? UIColor, .black)
        let textPresets = PSPDFKit.sharedInstance.styleManager.presets(forKey: AnnotationStateVariantID(rawValue: AnnotationString.freeText.rawValue), type: .colorPreset) as? [PSPDFColorPreset]
        XCTAssertNotNil(textPresets)
        XCTAssertEqual(textPresets?.count, DocViewerAnnotationColor.allCases.count * 2)
        for annotationColor in DocViewerAnnotationColor.allCases {
            XCTAssertTrue(textPresets?.contains { $0.color == annotationColor.color && $0.fillColor?.hexString == UIColor.white.hexString } == true)
            XCTAssertTrue(textPresets?.contains { $0.color == annotationColor.color && $0.fillColor == nil } == true)
        }
    }
}
