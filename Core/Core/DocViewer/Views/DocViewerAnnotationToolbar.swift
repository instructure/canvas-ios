//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

public class DocViewerAnnotationToolbar: AnnotationToolbar {
    public var showDoneButton: Bool = true

    override public var doneButton: UIButton? {
        return showDoneButton ? super.doneButton : nil
    }

    public override init(annotationStateManager: AnnotationStateManager) {
        super.init(annotationStateManager: annotationStateManager)

        let commentGroupItem = AnnotationToolConfiguration.ToolItem(type: .stamp, variant: nil) { (_, _, _) in
            return UIImage.markerSolid
        }
        let commentGroup = AnnotationToolConfiguration.ToolGroup(items: [commentGroupItem])

        let highlightGroupItem = AnnotationToolConfiguration.ToolItem(type: .highlight, variant: nil, configurationBlock: { (_, _, _) in
            return UIImage.highlighterSolid
        })
        let highlightGroup = AnnotationToolConfiguration.ToolGroup(items: [highlightGroupItem])

        let freeTextGroupItem = AnnotationToolConfiguration.ToolItem(type: .freeText, variant: nil) { (_, _, _) in
            return UIImage.textLine
        }
        let freeTextGroup = AnnotationToolConfiguration.ToolGroup(items: [freeTextGroupItem])

        let strikeoutGroupItem = AnnotationToolConfiguration.ToolItem(type: .strikeOut, variant: nil, configurationBlock: { (_, _, _) in
            return UIImage.strikethroughSolid
        })
        let strikeoutGroup = AnnotationToolConfiguration.ToolGroup(items: [strikeoutGroupItem])

        let inkGroupItem = AnnotationToolConfiguration.ToolItem(type: .ink, variant: nil) { (_, _, _) in
            return UIImage.paintSolid
        }
        let inkGroup = AnnotationToolConfiguration.ToolGroup(items: [inkGroupItem])

        let boxGroupItem = AnnotationToolConfiguration.ToolItem(type: .square, variant: nil) { (_, _, _) in
            return UIImage.boxSolid
        }
        let boxGroup = AnnotationToolConfiguration.ToolGroup(items: [boxGroupItem])

        let eraserGroupItem = AnnotationToolConfiguration.ToolItem(type: .eraser, variant: nil)
        let eraserGroup = AnnotationToolConfiguration.ToolGroup(items: [eraserGroupItem])

        self.configurations = [AnnotationToolConfiguration(annotationGroups: [commentGroup, highlightGroup, freeTextGroup, strikeoutGroup, boxGroup, inkGroup, eraserGroup])]
        self.supportedToolbarPositions = .inTopBar
        self.isDragEnabled = false
        self.showDoneButton = false
    }
}
