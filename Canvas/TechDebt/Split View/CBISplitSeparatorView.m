//
//  CBISplitSeparatorView.m
//  iCanvas
//
//  Created by derrick on 12/31/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBISplitSeparatorView.h"
@import SoPretty;


@interface CBISplitSeparatorView ()
@property (nonatomic) CALayer *separatorLayer;
@end

@implementation CBISplitSeparatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor clearColor];
        self.color = [UIColor prettyGray];
        _separatorLayer = [CALayer layer];
        [self.layer addSublayer:_separatorLayer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGRect frame = self.bounds;
    CGFloat lineWidth = 1/[UIScreen mainScreen].scale;
    frame.origin.x = frame.size.width - lineWidth;
    frame.size.width = lineWidth;
    self.separatorLayer.frame = frame;
    self.separatorLayer.backgroundColor = self.color.CGColor;
    [CATransaction commit];
}

@end
