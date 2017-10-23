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


