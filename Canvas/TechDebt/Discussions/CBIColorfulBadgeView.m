//
//  CBIColorfulBadgeView.m
//  iCanvas
//
//  Created by derrick on 1/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulBadgeView.h"

@implementation CBIColorfulBadgeView

- (void)awakeFromNib
{
    self.layer.cornerRadius = self.bounds.size.height / 2.f;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;
}

@end
