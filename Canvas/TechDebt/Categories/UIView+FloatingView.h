//
//  UIView+FloatingView.h
//  iCanvas
//
//  Created by BJ Homer on 2/15/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UIView (FloatingView)

- (void)floatIntoView:(UIView *)newView belowSubview:(UIView *)sibling;

- (void)floatIntoWindow;
- (void)unfloatIntoView:(UIView *)newSuperview;
- (CGAffineTransform)transformForInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (CGAffineTransform)transformForCurrentInterfaceOrientation;
@end


