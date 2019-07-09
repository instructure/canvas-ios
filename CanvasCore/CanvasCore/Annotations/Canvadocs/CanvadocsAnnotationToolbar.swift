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

public class CanvadocsAnnotationToolbar: PSPDFAnnotationToolbar {
    
    @objc public var showDoneButton: Bool = true

    override public var doneButton: UIButton? {
        return showDoneButton ? super.doneButton : nil
    }
    
    public override init(annotationStateManager: PSPDFAnnotationStateManager) {
        super.init(annotationStateManager: annotationStateManager)
        
        let commentGroupItem = PSPDFAnnotationGroupItem(type: .stamp, variant: nil) { (item, container, tintColor) in
            return UIImage(named: "pin", in: Bundle(for: CanvadocsAnnotationToolbar.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        }
        let commentGroup = PSPDFAnnotationGroup(items: [commentGroupItem])
        
        let highlightGroupItem = PSPDFAnnotationGroupItem(type: .highlight, variant: nil, configurationBlock: { (item, container, tintColor) in
            return UIImage(named: "highlight", in: Bundle(for: CanvadocsAnnotationToolbar.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        })
        let highlightGroup = PSPDFAnnotationGroup(items: [highlightGroupItem])
        
        let freeTextGroupItem = PSPDFAnnotationGroupItem(type: .freeText, variant: nil) { (item, container, tintColor) in
            return UIImage(named: "text_box", in: Bundle(for: CanvadocsAnnotationToolbar.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        }
        let freeTextGroup = PSPDFAnnotationGroup(items: [freeTextGroupItem])
        
        let strikeoutGroupItem = PSPDFAnnotationGroupItem(type: .strikeOut, variant: nil, configurationBlock: { (item, container, tintColor) in
            return UIImage(named: "strike_through", in: Bundle(for: CanvadocsAnnotationToolbar.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        })
        let strikeoutGroup = PSPDFAnnotationGroup(items: [strikeoutGroupItem])
        
        let inkGroupItem = PSPDFAnnotationGroupItem(type: .ink, variant: nil) { (item, container, tintColor) in
            return UIImage(named: "draw", in: Bundle(for: CanvadocsAnnotationToolbar.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        }
        let inkGroup = PSPDFAnnotationGroup(items: [inkGroupItem])
        
        let boxGroupItem = PSPDFAnnotationGroupItem(type: .square, variant: nil) { (item, container, tintColor) in
            return UIImage(named: "rectangle", in: Bundle(for: CanvadocsAnnotationToolbar.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        }
        let boxGroup = PSPDFAnnotationGroup(items: [boxGroupItem])

        let eraserGroupItem = PSPDFAnnotationGroupItem(type: .eraser, variant: nil)
        let eraserGroup = PSPDFAnnotationGroup(items: [eraserGroupItem])
        
        self.configurations = [PSPDFAnnotationToolbarConfiguration(annotationGroups: [commentGroup, highlightGroup, freeTextGroup, strikeoutGroup, boxGroup, inkGroup, eraserGroup])]
    }
}
