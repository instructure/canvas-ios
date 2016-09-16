//
//  UIView+DebugQuickLook.m
//  Cloud Palettes
//
//  Created by Derrick Hathaway on 3/11/14.
//  Copyright (c) 2014 The Best Bits LLC. All rights reserved.
//

#import "UIView+DebugQuickLook.h"

@implementation UIView (DebugQuickLook)
#ifdef DEBUG
- (id)debugQuickLookObject {
    CGRect bounds = self.bounds;
    if (bounds.size.width < 0.0 || bounds.size.height < 0.0) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, self.window.screen.scale);
    [self drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
#endif
@end
