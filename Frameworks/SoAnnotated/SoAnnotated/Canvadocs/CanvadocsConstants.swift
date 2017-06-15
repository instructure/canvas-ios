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
        return UIColor(rgba: self.rawValue)
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
        return UIColor(rgba: self.rawValue)
    }
}



@objc public class AppAnnotationsConfiguration: NSObject {
    public class func canvasAndSpeedgraderConfig() -> PSPDFConfiguration {
        return canvasAppConfiguration
    }
    
    public class func teacherConfig() -> PSPDFConfiguration {
        return teacherAppConfiguration
    }
}

public let canvasAppConfiguration: PSPDFConfiguration = {
    return PSPDFConfiguration { (builder) -> Void in
        builder.shouldAskForAnnotationUsername = false
        builder.pageTransition = PSPDFPageTransition.scrollContinuous
        builder.scrollDirection = PSPDFScrollDirection.vertical
        builder.fitToWidthEnabled = .YES
        builder.pagePadding = 5.0
        builder.isRenderAnimationEnabled = false
        builder.shouldHideNavigationBarWithHUD = false
        builder.shouldHideStatusBarWithHUD = false
        builder.applicationActivities = [PSPDFActivityTypeOpenIn, PSPDFActivityTypeGoToPage, PSPDFActivityTypeSearch]
        builder.editableAnnotationTypes = [.highlight, .strikeOut, .freeText, .note, .ink, .square, .circle, .line]
        builder.drawCreateMode = .separate
        builder.naturalDrawingAnnotationEnabled = false
        builder.propertiesForAnnotations = [
            .highlight: [["color"]],
            PSPDFAnnotationStateVariantIdentifier(.ink, .inkVariantPen): [["color"]],
            .square: [["color"]],
            .circle: [["color"]],
            .line: [["color"]],
            .strikeOut: [[]],
            .freeText: [["fontSize"]],
        ]
    }
}()

public let teacherAppConfiguration: PSPDFConfiguration = {
    return PSPDFConfiguration { (builder) -> Void in
        builder.shouldAskForAnnotationUsername = false
        builder.pageTransition = PSPDFPageTransition.scrollContinuous
        builder.scrollDirection = PSPDFScrollDirection.vertical
        builder.fitToWidthEnabled = .YES
        builder.pagePadding = 5.0
        builder.isRenderAnimationEnabled = true
        builder.shouldHideNavigationBarWithHUD = false
        builder.shouldHideStatusBarWithHUD = false
        builder.applicationActivities = [PSPDFActivityTypeOpenIn, PSPDFActivityTypeGoToPage, PSPDFActivityTypeSearch]
        builder.editableAnnotationTypes = [.highlight, .strikeOut, .freeText, .note, .ink]
        builder.drawCreateMode = .separate
        builder.naturalDrawingAnnotationEnabled = false
        
        // This version of PSPDFKit is way buggy... so lets reenable all the options, while they work out the bugs.
        // As of now (6/13/17), they say the fixes are on the way in 1-2 weeks.
//        builder.propertiesForAnnotations = [
//            .highlight: [["color"]],
//            PSPDFAnnotationStateVariantIdentifier(.ink, .inkVariantPen): [["color"]],
//            .square: [["color"]],
//            .circle: [["color"]],
//            .line: [["color"]],
//            .strikeOut: [[]],
//            .freeText: [["fontSize"]],
//        ]
        
        builder.backgroundColor = UIColor(red: 165.0/255.0, green: 175.0/255.0, blue: 181.0/255.0, alpha: 1.0)
        builder.hudViewMode = .never
    }
}()



