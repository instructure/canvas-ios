//
//  CBISplitTransitionShadowView.m
//  iCanvas
//
//  Created by derrick on 1/4/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBISplitTransitionShadowView.h"

@implementation CBISplitTransitionShadowView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        CAGradientLayer *layer = (CAGradientLayer *)self.layer;
        layer.colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[UIColor colorWithWhite:0 alpha:0.20].CGColor];
        layer.startPoint = CGPointMake(0., 0.5);
        layer.endPoint = CGPointMake(1., 0.5);

    }
    return self;
}

@end
