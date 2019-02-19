//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import PSPDFKit
import PSPDFKitUI

enum DocViewerAnnotationColor: String, CaseIterable {
    case red = "#EE0612"
    case orange = "#FC5E13"
    case yellow = "#FCB900"
    case brown = "#8D6437"
    case green = "#00AC18"
    case darkBlue = "#234C9F"
    case blue = "#008EE2"
    case pink = "#C31FA8"
    case purple = "#741865"
    case darkGray = "#363636"

    var color: UIColor {
        return UIColor(hexString: self.rawValue)!
    }
}

enum DocViewerHighlightColor: String, CaseIterable {
    case red = "#FF9999"
    case orange = "#FFC166"
    case yellow = "#FCE680"
    case green = "#99EBA4"
    case blue = "#80D0FF"
    case pink = "#FFB9F1"

    var color: UIColor {
        return UIColor(hexString: self.rawValue)!
    }
}

func docViewerConfigurationBuilder(_ builder: PSPDFConfigurationBuilder) {
    builder.additionalScrollViewFrameInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    builder.backgroundColor = .named(.borderMedium)
    builder.editableAnnotationTypes = [.stamp, .highlight, .freeText, .strikeOut, .ink, .eraser, .square]
    builder.isRenderAnimationEnabled = true
    builder.naturalDrawingAnnotationEnabled = true
    builder.pageMode = .single
    builder.pageTransition = .scrollContinuous
    builder.scrollDirection = .vertical
    builder.shouldAskForAnnotationUsername = false
    builder.shouldHideNavigationBarWithUserInterface = false
    builder.shouldHideStatusBarWithUserInterface = false
    builder.spreadFitting = .fill
    builder.userInterfaceViewMode = .never

    builder.propertiesForAnnotations = [
        .stamp: [["color"]],
        .highlight: [["color"]],
        .ink: [["color"]],
        .square: [["color"]],
        .circle: [["color"]],
        .line: [["color"]],
        .strikeOut: [[]],
        .freeText: [["fontSize"]],
    ]

    builder.overrideClass(PSPDFAnnotationToolbar.self, with: DocViewerAnnotationToolbar.self)
    builder.overrideClass(PSPDFAnnotationStateManager.self, with: DocViewerAnnotationStateManager.self)
}

func stylePSPDFKit() {
    let styleManager = PSPDFKit.sharedInstance.styleManager
    styleManager.setupDefaultStylesIfNeeded()

    let highlightPresets = DocViewerHighlightColor.allCases.map { return PSPDFColorPreset(color: $0.color) }
    let inkPresets = DocViewerAnnotationColor.allCases.map { return PSPDFColorPreset(color: $0.color) }
    let textPresets = DocViewerAnnotationColor.allCases.map { return PSPDFColorPreset(color: $0.color, fill: .white, alpha: 1) }
    styleManager.setPresets(highlightPresets, forKey: AnnotationStateVariantID(rawValue: AnnotationString.highlight.rawValue), type: AnnotationStyleType.colorPreset)
    styleManager.setPresets(inkPresets, forKey: AnnotationStateVariantID(rawValue: AnnotationString.ink.rawValue), type: .colorPreset)
    styleManager.setPresets(inkPresets, forKey: AnnotationStateVariantID(rawValue: AnnotationString.square.rawValue), type: .colorPreset)
    styleManager.setPresets(inkPresets, forKey: AnnotationStateVariantID(rawValue: AnnotationString.circle.rawValue), type: .colorPreset)
    styleManager.setPresets(inkPresets, forKey: AnnotationStateVariantID(rawValue: AnnotationString.line.rawValue), type: .colorPreset)
    styleManager.setPresets(inkPresets, forKey: AnnotationStateVariantID(rawValue: AnnotationString.strikeOut.rawValue), type: .colorPreset)
    styleManager.setPresets(inkPresets, forKey: AnnotationStateVariantID(rawValue: AnnotationString.stamp.rawValue), type: .colorPreset)
    styleManager.setPresets(textPresets, forKey: AnnotationStateVariantID(rawValue: AnnotationString.freeText.rawValue), type: .colorPreset)

    styleManager.setLastUsedValue(DocViewerHighlightColor.yellow.color, forProperty: "color", forKey: AnnotationStateVariantID(rawValue: AnnotationString.highlight.rawValue))
    styleManager.setLastUsedValue(DocViewerAnnotationColor.red.color, forProperty: "color", forKey: AnnotationStateVariantID(rawValue: AnnotationString.ink.rawValue))
    styleManager.setLastUsedValue(DocViewerAnnotationColor.red.color, forProperty: "color", forKey: AnnotationStateVariantID(rawValue: AnnotationString.square.rawValue))
    styleManager.setLastUsedValue(DocViewerAnnotationColor.red.color, forProperty: "color", forKey: AnnotationStateVariantID(rawValue: AnnotationString.circle.rawValue))
    styleManager.setLastUsedValue(DocViewerAnnotationColor.red.color, forProperty: "color", forKey: AnnotationStateVariantID(rawValue: AnnotationString.line.rawValue))
    styleManager.setLastUsedValue(DocViewerAnnotationColor.red.color, forProperty: "color", forKey: AnnotationStateVariantID(rawValue: AnnotationString.strikeOut.rawValue))
    styleManager.setLastUsedValue(DocViewerAnnotationColor.blue.color, forProperty: "color", forKey: AnnotationStateVariantID(rawValue: AnnotationString.stamp.rawValue))
    styleManager.setLastUsedValue(UIColor.black, forProperty: "color", forKey: AnnotationStateVariantID(rawValue: AnnotationString.freeText.rawValue))
    styleManager.setLastUsedValue(UIColor.white, forProperty: "fillColor", forKey: AnnotationStateVariantID(rawValue: AnnotationString.freeText.rawValue))
    styleManager.setLastUsedValue("Verdana", forProperty: "fontName", forKey: AnnotationStateVariantID(rawValue: AnnotationString.freeText.rawValue))
    styleManager.setLastUsedValue(14, forProperty: "fontSize", forKey: AnnotationStateVariantID(rawValue: AnnotationString.freeText.rawValue))
    styleManager.setLastUsedValue(2.0, forProperty: "lineWidth", forKey: AnnotationStateVariantID(rawValue: AnnotationString.ink.rawValue))
    styleManager.setLastUsedValue(2.0, forProperty: "lineWidth", forKey: AnnotationStateVariantID(rawValue: AnnotationString.square.rawValue))
    styleManager.setLastUsedValue(2.0, forProperty: "lineWidth", forKey: AnnotationStateVariantID(rawValue: AnnotationString.circle.rawValue))
    styleManager.setLastUsedValue(2.0, forProperty: "lineWidth", forKey: AnnotationStateVariantID(rawValue: AnnotationString.line.rawValue))
}
