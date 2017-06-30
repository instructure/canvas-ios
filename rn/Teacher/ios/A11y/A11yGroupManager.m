//
//  A11yGroupViewManager.m
//  Teacher
//
//  Created by Derrick Hathaway on 6/29/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Teacher-Swift.h"
#import <React/RCTUIManager.h>

@interface A11yGroupManager: RCTViewManager
@end

@implementation A11yGroupManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    RCTView *a11yGroup = [RCTView new];
    a11yGroup.shouldGroupAccessibilityChildren = YES;
    return a11yGroup;
}

@end
