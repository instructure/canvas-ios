//
//  PSPDFScrollView+Fixed.swift
//  SoAnnotated
//
//  Created by Ben Kraus on 6/13/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation
import PSPDFKit


// Peter gave me the real implementation... it looks like this:
//
//- (void)setParentScrollViewScrollPagingEnabled:(BOOL)enable {
//    UIScrollView *parentScrollView = [self parentScrollView];
//    // Enable scrolling only if it's enabled on the pdf controller,
//    // if `twoFingerScrollAndZoomModeEnabled` is set as well, make sure that we don't disable scrolling here,
//    // so we can use two fingers to pan to a different page
//    let context = self.presentationContext;
//    parentScrollView.scrollEnabled = context.isScrollingEnabled && (enable || context.pdfController.scrollTouchMode == PSPDFScrollTouchModeTwoFingers);
//}
//
// That should only be happening when scrollDirection is set to horizontal, so I fixed it by swizzling, yay!

extension PSPDFScrollView {
    
    public static func swizzleAllTehThings() {
        let originalSelector = Selector(("setParentScrollViewScrollPagingEnabled:"))
        let swizzledSelector = #selector(PSPDFScrollView.cnvs_setParentScrollViewScrollPagingEnabled(_:))
        
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    func cnvs_setParentScrollViewScrollPagingEnabled(_ enable: Bool) {
        if presentationContext?.pdfController.configuration.scrollDirection == .vertical && presentationContext?.pdfController.configuration.pageTransition == .scrollContinuous {
            // Do nothing, yay!
        } else {
            // Call the swizzled method - the method implementations have been swapped, so it'll actually call the proper one inside PSPDFKit
            cnvs_setParentScrollViewScrollPagingEnabled(enable)
        }
    }
}


