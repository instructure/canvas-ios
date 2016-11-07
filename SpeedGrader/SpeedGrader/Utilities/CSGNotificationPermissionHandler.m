//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
