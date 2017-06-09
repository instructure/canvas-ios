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

let canvadocsAnnotationBlackColor = UIColor(rgba: "#000000")
let canvadocsAnnotationRedColor = UIColor(rgba: "#FF0000")
let canvadocsAnnotationBlueColor = UIColor(rgba: "#0000FF")
let canvadocsAnnotationGreenColor = UIColor(rgba: "#00AA00")

let canvadocsHighlightAnnotationYellowColor = UIColor(rgba: "#FFF688")
let canvadocsHighlightAnnotationOrangeColor = UIColor(rgba: "#FCCC6A")
let canvadocsHighlightAnnotationGreenColor = UIColor(rgba: "#BFF694")
let canvadocsHighlightAnnotationBlueColor = UIColor(rgba: "#98DDFF")

let standardCanvadocsColors: [UIColor] = [canvadocsAnnotationBlackColor, canvadocsAnnotationRedColor, canvadocsAnnotationBlueColor, canvadocsAnnotationGreenColor]
let highlightCanvadocsColors: [UIColor] = [canvadocsHighlightAnnotationYellowColor, canvadocsHighlightAnnotationOrangeColor, canvadocsHighlightAnnotationGreenColor, canvadocsHighlightAnnotationBlueColor]



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
        builder.backgroundColor = UIColor(red: 165.0/255.0, green: 175.0/255.0, blue: 181.0/255.0, alpha: 1.0)
        builder.hudViewMode = .never
    }
}()



