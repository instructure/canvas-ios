//
//  CSGToaster.h
//  SpeedGrader
//
//  Created by Nathan Lambson on 12/15/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//
//  REFER TO CBIToaster.h in iCanvas

#import <Foundation/Foundation.h>
@import CWStatusBarNotification;

@interface CSGToaster : NSObject

// Status bar toasts are for notifications that users can't interact with, e.g. "message sent"
- (CWStatusBarNotification *)statusBarToast:(NSString *)message Color:(UIColor *)color;
- (void)statusBarToast:(NSString *)message Color:(UIColor *)color Duration:(CGFloat)duration;

#pragma mark - Other Toasts
// TODO implement toasts (probably popping over navbar) that when user taps them, have an action.

@end
