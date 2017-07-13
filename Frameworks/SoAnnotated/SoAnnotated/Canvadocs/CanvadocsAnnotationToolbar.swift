//
//  CanvadocsAnnotationToolbar.swift
//  SoAnnotated
//
//  Created by Ben Kraus on 7/12/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import PSPDFKit

public class CanvadocsAnnotationToolbar: PSPDFAnnotationToolbar {
    
    public var showDoneButton: Bool = true
    
    override public var doneButton: UIButton? {
        return showDoneButton ? super.doneButton : nil
    }
    
    override public init(annotationStateManager: PSPDFAnnotationStateManager) {
        super.init(annotationStateManager: annotationStateManager)
        
        barTintColor = UIColor(rgba: "#556572")
        tintColor = .white
        
        let commentGroupItem = PSPDFAnnotationGroupItem(type: .note, variant: nil) { (item, container, tintColor) in
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
