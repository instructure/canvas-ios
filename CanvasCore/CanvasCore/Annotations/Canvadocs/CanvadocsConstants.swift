//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import UIKit
import PSPDFKit
import PSPDFKitUI

let standardCanvadocsColors: [UIColor] = CanvadocsAnnotationColor.allColors.map { $0.color }
let highlightCanvadocsColors: [UIColor] = CanvadocsHighlightColor.allColors.map { $0.color }

enum CanvadocsAnnotationColor: String {
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
    
    static var allColors: [CanvadocsAnnotationColor] = [.red, .orange, .yellow, .brown, .green, .darkBlue, .blue, .pink, .purple, .darkGray]
    
    var color: UIColor {
        return UIColor.colorFromHexString(self.rawValue)!
    }
}

enum CanvadocsHighlightColor: String {
    case red = "#FF9999"
    case orange = "#FFC166"
    case yellow = "#FCE680"
    case green = "#99EBA4"
    case blue = "#80D0FF"
    case pink = "#FFB9F1"
    
    static var allColors: [CanvadocsHighlightColor] = [.red, .orange, .yellow, .green, .blue, .pink]
    
    var color: UIColor {
        return UIColor.colorFromHexString(self.rawValue)!
    }
}



@objc public class AppAnnotationsConfiguration: NSObject {
    public class func canvasAndSpeedgraderConfig() -> PSPDFConfiguration {
        return canvasAppConfiguration
    }
    
    public class func teacherConfig(bottomInset: CGFloat) -> PSPDFConfiguration {
        return teacherAppConfiguration(bottomInset: bottomInset)
    }
}

func applySharedAppConfiguration(to builder: PSPDFConfigurationBuilder) {
    builder.shouldAskForAnnotationUsername = false
    builder.pageTransition = PSPDFPageTransition.scrollContinuous
    builder.scrollDirection = PSPDFScrollDirection.vertical
    builder.spreadFitting = .fill
    builder.additionalScrollViewFrameInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    builder.pageMode = .single
    builder.isRenderAnimationEnabled = true
    builder.shouldHideNavigationBarWithUserInterface = false
    builder.shouldHideStatusBarWithUserInterface = false
    builder.applicationActivities = [PSPDFActivityTypeOpenIn, PSPDFActivityTypeGoToPage, PSPDFActivityTypeSearch]
    builder.editableAnnotationTypes = [.stamp, .highlight, .freeText, .strikeOut, .ink, .square]
    builder.naturalDrawingAnnotationEnabled = true

    builder.propertiesForAnnotations = [
        .stamp: [["color"]],
        .highlight: [["color"]],
        PSPDFAnnotationStateVariantIdentifier(.ink, .inkVariantPen): [["color"]],
        .square: [["color"]],
        .circle: [["color"]],
        .line: [["color"]],
        .strikeOut: [[]],
        .freeText: [["fontSize"]],
    ]

    builder.overrideClass(PSPDFAnnotationToolbar.self, with: CanvadocsAnnotationToolbar.self)
    builder.overrideClass(PSPDFAnnotationStateManager.self, with: CanvadocsAnnotationStateManager.self)
}

public let canvasAppConfiguration: PSPDFConfiguration = {
    return PSPDFConfiguration { (builder) -> Void in
        applySharedAppConfiguration(to: builder)
    }
}()

public func teacherAppConfiguration(bottomInset: CGFloat) -> PSPDFConfiguration {
    return PSPDFConfiguration { (builder) -> Void in
        applySharedAppConfiguration(to: builder)
        builder.additionalScrollViewFrameInsets.bottom = bottomInset
        builder.backgroundColor = UIColor(red: 165.0/255.0, green: 175.0/255.0, blue: 181.0/255.0, alpha: 1.0)
        builder.userInterfaceViewMode = .never
    }
}



