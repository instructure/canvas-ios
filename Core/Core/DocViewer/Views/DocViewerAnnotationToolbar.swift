//
// Copyright (C) 2017-present Instructure, Inc.
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

public class DocViewerAnnotationToolbar: PSPDFAnnotationToolbar {
    public var showDoneButton: Bool = true

    override public var doneButton: UIButton? {
        return showDoneButton ? super.doneButton : nil
    }

    public override init(annotationStateManager: PSPDFAnnotationStateManager) {
        super.init(annotationStateManager: annotationStateManager)

        let commentGroupItem = PSPDFAnnotationGroupItem(type: .stamp, variant: nil) { (_, _, _) in
            return UIImage.icon(.marker, .solid)
        }
        let commentGroup = PSPDFAnnotationGroup(items: [commentGroupItem])

        let highlightGroupItem = PSPDFAnnotationGroupItem(type: .highlight, variant: nil, configurationBlock: { (_, _, _) in
            return UIImage.icon(.highlighter, .solid)
        })
        let highlightGroup = PSPDFAnnotationGroup(items: [highlightGroupItem])

        let freeTextGroupItem = PSPDFAnnotationGroupItem(type: .freeText, variant: nil) { (_, _, _) in
            return UIImage.icon(.text, .line)
        }
        let freeTextGroup = PSPDFAnnotationGroup(items: [freeTextGroupItem])

        let strikeoutGroupItem = PSPDFAnnotationGroupItem(type: .strikeOut, variant: nil, configurationBlock: { (_, _, _) in
            return UIImage.icon(.strikethrough, .solid)
        })
        let strikeoutGroup = PSPDFAnnotationGroup(items: [strikeoutGroupItem])

        let inkGroupItem = PSPDFAnnotationGroupItem(type: .ink, variant: nil) { (_, _, _) in
            return UIImage.icon(.paint, .solid)
        }
        let inkGroup = PSPDFAnnotationGroup(items: [inkGroupItem])

        let boxGroupItem = PSPDFAnnotationGroupItem(type: .square, variant: nil) { (_, _, _) in
            return UIImage.icon(.box, .solid)
        }
        let boxGroup = PSPDFAnnotationGroup(items: [boxGroupItem])

        let eraserGroupItem = PSPDFAnnotationGroupItem(type: .eraser, variant: nil)
        let eraserGroup = PSPDFAnnotationGroup(items: [eraserGroupItem])

        self.configurations = [PSPDFAnnotationToolbarConfiguration(annotationGroups: [commentGroup, highlightGroup, freeTextGroup, strikeoutGroup, boxGroup, inkGroup, eraserGroup])]
    }
}
