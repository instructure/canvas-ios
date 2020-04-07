//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import PSPDFKit
import PSPDFKitUI

@objc public class AppAnnotationsConfiguration: NSObject {
    @objc public class func canvasAndSpeedgraderConfig() -> PDFConfiguration {
        return canvasAppConfiguration
    }
    
    @objc public class func teacherConfig(bottomInset: CGFloat) -> PDFConfiguration {
        return teacherAppConfiguration(bottomInset: bottomInset)
    }
}

func applySharedAppConfiguration(to builder: PDFConfigurationBuilder) {
    builder.shouldAskForAnnotationUsername = false
    builder.pageTransition = PageTransition.scrollContinuous
    builder.scrollDirection = ScrollDirection.vertical
    builder.spreadFitting = .fill
    builder.additionalScrollViewFrameInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    builder.pageMode = .single
    builder.isRenderAnimationEnabled = true
    builder.shouldHideNavigationBarWithUserInterface = false
    builder.shouldHideStatusBarWithUserInterface = false
    builder.editableAnnotationTypes = [.stamp, .highlight, .freeText, .strikeOut, .ink, .eraser, .square]
    builder.naturalDrawingAnnotationEnabled = true

    let properties: [Annotation.Tool: [[AnnotationStyle.Key]]] = [
        .stamp: [[.color]],
        .highlight: [[.color]],
        .ink: [[.color, .lineWidth]],
        .square: [[.color]],
        .line: [[.color]],
        .strikeOut: [[]],
        .freeText: [[.fontSize]]
    ]
    builder.propertiesForAnnotations = properties

    builder.overrideClass(AnnotationToolbar.self, with: CanvadocsAnnotationToolbar.self)
    builder.overrideClass(AnnotationStateManager.self, with: CanvadocsAnnotationStateManager.self)
}

public let canvasAppConfiguration: PDFConfiguration = {
    return PDFConfiguration { (builder) -> Void in
        applySharedAppConfiguration(to: builder)
    }
}()

public func teacherAppConfiguration(bottomInset: CGFloat) -> PDFConfiguration {
    return PDFConfiguration { (builder) -> Void in
        applySharedAppConfiguration(to: builder)
        builder.additionalScrollViewFrameInsets.bottom = bottomInset
        builder.backgroundColor = UIColor(red: 165.0/255.0, green: 175.0/255.0, blue: 181.0/255.0, alpha: 1.0)
        builder.userInterfaceViewMode = .never
        builder.naturalDrawingAnnotationEnabled = false
    }
}



