//
//  CSGNotificationPermissionHandler.m
//  SpeedGrader
//
//  Created by Nathan Lambson on 11/10/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGNotificationPermissionHandler.h"

@implementation CSGNotificationPermissionHandler

static const UIUserNotificationType USER_NOTIFICATION_TYPES_REQUIRED = UIUserNotificationTypeBadge;

+ (void)checkPermissions {
    bool isIOS8OrGreater = [[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)];
    if (!isIOS8OrGreater)
    {
        [CSGNotificationPermissionHandler iOS7AndBelowPermissions];
        return;
    }
    
    [CSGNotificationPermissionHandler iOS8AndAbovePermissions];
}

+ (void)iOS7AndBelowPermissions {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

+ (void)iOS8AndAbovePermissions {
    if ([CSGNotificationPermissionHandler canSendNotifications])
    {
        return;
    }
    
    UIUserNotificationSettings* requestedSettings = [UIUserNotificationSettings settingsForTypes:USER_NOTIFICATION_TYPES_REQUIRED categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:requestedSettings];
}

+ (bool)canSendNotifications {
    UIApplication *application = [UIApplication sharedApplication];
    bool isIOS8OrGreater = [application respondsToSelector:@selector(currentUserNotificationSettings)];
    
    if (!isIOS8OrGreater)
    {
        // We actually just don't know if we can, no way to tell programmatically before iOS8
        return true;
    }
    
    UIUserNotificationSettings* notificationSettings = [application currentUserNotificationSettings];
    bool canSendNotifications = notificationSettings.types == USER_NOTIFICATION_TYPES_REQUIRED;
    
    return canSendNotifications;
}

@end
