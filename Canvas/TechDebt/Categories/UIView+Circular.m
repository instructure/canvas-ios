//
//  UIImageView+RoundImage.m
//  Canvas2.0 Prototype
//
//  Created by Jason Larsen on 2/5/13.
//  Copyright (c) 2013 Jason Larsen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIView+Circular.h"

@implementation UIView (Circular)

- (void)makeViewCircular
{
    self.clipsToBounds = YES;
    CGRect squareFrame = self.frame;
    CGFloat side = MIN(self.frame.size.width, self.frame.size.height);
    squareFrame.size.height = side;
    squareFrame.size.width = side;
    self.frame = CGRectIntegral(squareFrame);
    self.layer.cornerRadius = (side/2);
}

- (void)makeViewRectangular
{
    self.layer.cornerRadius = 0;
}

@end
