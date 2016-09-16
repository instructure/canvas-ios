//
//  NonResponsiveTextField.m
//  iCanvas
//
//  Created by BJ Homer on 7/21/11.
//  Copyright 2011 Instructure. All rights reserved.
//

#import "NonResponsiveTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation NonResponsiveTextField {
    UIImageView *imageView;
}

- (BOOL)isAccessibilityElement {
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return NO;
}


- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow != nil) {
        UITextField *textField = [[UITextField alloc] initWithFrame:self.bounds];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
        [textField.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [imageView removeFromSuperview];
        
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        
        image = [image resizableImageWithCapInsets:(UIEdgeInsets) {
            .top = 8,
            .right = 8,
            .bottom = 8,
            .left = 8
        }];
        imageView.image = image;
        [self insertSubview:imageView atIndex:0];
        self.backgroundColor = [UIColor clearColor];
    }
    [super willMoveToWindow:newWindow];
}

@end
