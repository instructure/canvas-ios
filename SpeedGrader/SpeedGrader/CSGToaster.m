//
//  CSGToaster.m
//  SpeedGrader
//
//  Created by Nathan Lambson on 12/15/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGToaster.h"
#import "UIColor+Canvas.h"

static float DefaultToastDuration = 2.65f;

@interface CSGToaster ()

@end

@implementation CSGToaster

#pragma mark - Status Bar Toasts

- (CWStatusBarNotification *)statusBarToast:(NSString *)message Color:(UIColor *)color
{
    CWStatusBarNotification *notification = [[CWStatusBarNotification alloc] init];
    notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    notification.notificationLabelTextColor = [UIColor whiteColor];
    notification.notificationLabelBackgroundColor = color;
    
    [notification displayNotificationWithMessage:message forDuration:DefaultToastDuration];
    return notification;
}

- (void)statusBarToast:(NSString *)message Color:(UIColor *)color Duration:(CGFloat)duration
{
    CWStatusBarNotification *notification = [[CWStatusBarNotification alloc] init];
    notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    notification.notificationLabelTextColor = [UIColor whiteColor];
    notification.notificationLabelBackgroundColor = color;
    
    [notification displayNotificationWithMessage:message forDuration:duration];
}


@end
