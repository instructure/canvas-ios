//
//  UITableViewCell+Separator.m
//  iCanvas
//
//  Created by Jason Larsen on 7/9/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "UITableViewCell+Separator.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@implementation UITableViewCell (Separator)
static const void *separatorLineColorPropertyKey = &separatorLineColorPropertyKey;
- (UIColor *)separatorLineColor {
    return objc_getAssociatedObject(self, separatorLineColorPropertyKey);
}

- (void)setSeparatorLineColor:(UIColor *)color {
    objc_setAssociatedObject(self, separatorLineColorPropertyKey, color, OBJC_ASSOCIATION_RETAIN);
    
    UIView *backgroundView = self.backgroundView;
    if (!backgroundView) {
        backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = self.backgroundColor;
    }
    
    [self.viewForBaselineLayout layoutIfNeeded];
    
    static CGFloat SeparatorHeight = 1.0f;
    CGRect separatorRect, contentRect;
    CGRect frame = self.contentView.frame;
    CGRectDivide(frame, &separatorRect, &contentRect, SeparatorHeight, CGRectMaxYEdge);
    
    UIView *separatorView = [[UIView alloc] initWithFrame:separatorRect];
    separatorView.backgroundColor = color;
    [backgroundView addSubview:separatorView];
    self.backgroundView = backgroundView;
}
@end
