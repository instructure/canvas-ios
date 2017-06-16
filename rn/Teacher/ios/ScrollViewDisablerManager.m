//
//  ScrollViewDisabler.m
//  Teacher
//
//  Created by Layne Moseley on 6/16/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import "ScrollViewDisablerManager.h"
#import <React/RCTBridge.h>
#import <React/RCTView.h>

@interface ScrollViewDisabler : RCTView
@end

@implementation ScrollViewDisablerManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [[ScrollViewDisabler alloc] init];
}

@end

@implementation ScrollViewDisabler

- (void)layoutSubviews {
    [super layoutSubviews];
    [self disableScrolling:self];
}

- (void)disableScrolling:(UIView *)parent {
    for (UIView *view in parent.subviews) {
        UIScrollView *scrollView = (UIScrollView *)view;
        if ([scrollView isKindOfClass:[UIScrollView class]]) {
            scrollView.scrollEnabled = NO;
        }
        [self disableScrolling:view];
    }
}

@end
