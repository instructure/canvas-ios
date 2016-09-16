//
//  MKNumberBadgeView+CanvasStyle.m
//  iCanvas
//
//  Created by BJ Homer on 4/2/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "MKNumberBadgeView+CanvasStyle.h"

#import "UIFont+Canvas.h"

@import SoPretty;

@implementation MKNumberBadgeView (CanvasStyle)

+ (instancetype)badgeViewForView:(UIView *)view
{
    MKNumberBadgeView *badgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(0, -10, view.bounds.size.width+6, 24)];
    badgeView.pad = 0;
    badgeView.shadow = NO;
    badgeView.shine = NO;
    badgeView.shadowOffset = CGSizeMake(0, 2);
    badgeView.font = [UIFont canvasFontOfSize:12];
    badgeView.alignment = NSTextAlignmentRight;
    badgeView.userInteractionEnabled = NO;
    badgeView.hideWhenZero = YES;
    badgeView.fillColor = Brand.current.tintColor;
    badgeView.strokeColor = Brand.current.tintColor;
    badgeView.strokeWidth = 0;
    return badgeView;
}

@end
