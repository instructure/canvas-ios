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

public class CanvadocsAnnotationToolbar: PSPDFAnnotationToolbar {
    
    public var showDoneButton: Bool = true
    
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
        
        let inkGroupItem = PSPDFAnnotationGroupItem(type: .ink, variant: .inkVariantPen) { (item, container, tintColor) in
            return UIImage(named: "draw", in: Bundle(for: CanvadocsAnnotationToolbar.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        }
        let inkGroup = PSPDFAnnotationGroup(items: [inkGroupItem])
        
        let boxGroupItem = PSPDFAnnotationGroupItem(type: .square, variant: nil) { (item, container, tintColor) in
            return UIImage(named: "rectangle", in: Bundle(for: CanvadocsAnnotationToolbar.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        }
        let boxGroup = PSPDFAnnotationGroup(items: [boxGroupItem])
        
        self.configurations = [PSPDFAnnotationToolbarConfiguration(annotationGroups: [commentGroup, highlightGroup, freeTextGroup, strikeoutGroup, inkGroup, boxGroup])]
    }
}
