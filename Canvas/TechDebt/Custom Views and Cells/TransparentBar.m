//
//  TransparentBar.m
//  iCanvas
//
//  Created by BJ Homer on 7/8/11.
//  Copyright 2011 Instructure. All rights reserved.
//

#import "TransparentBar.h"

@implementation TransparentBar

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib {
    [self setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.translucent = YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        // If they don't hit a subview, pass through
        return nil;
    }
    return hitView;
}

@end
