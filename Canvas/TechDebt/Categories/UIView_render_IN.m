//
//  UIView_render_IN.m
//  iCanvas
//
//  Created by BJ Homer on 7/25/11.
//  Copyright 2011 Instructure. All rights reserved.
//

#import "UIView_render_IN.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (UIView_render_IN)

- (UIImage *)in_renderedImageOfSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
