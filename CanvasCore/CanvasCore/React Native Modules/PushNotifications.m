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

#import "PushNotifications.h"
#import <React/RCTConvert.h>

NSString * const PushNotificationsStorageKey = @"PushNotificationsStorageKey";

@import UserNotifications;

@implementation PushNotifications

+ (void)recordNotification:(UNNotification *)notification
{
    NSDictionary *payload = notification.request.content.userInfo;
    NSArray *existing = [[NSUserDefaults standardUserDefaults] arrayForKey:PushNotificationsStorageKey];
    NSArray *all = existing ? [existing arrayByAddingObject:payload] : @[payload];
    [[NSUserDefaults standardUserDefaults] setObject:all forKey:PushNotificationsStorageKey];
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(requestPermissions)
{
    if (NSClassFromString(@"EarlGreyImpl") != nil) {
        return;
    }

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge;
    
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(granted ? @"YES" : @"NO");
    }];
}

RCT_EXPORT_METHOD(scheduleLocalNotification:(NSDictionary *)notification)
{
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = [RCTConvert NSString:notification[@"title"]];
    content.body = [RCTConvert NSString:notification[@"body"]];
    content.sound = [UNNotificationSound defaultSound];
    
    NSTimeInterval fireDate = [RCTConvert NSTimeInterval:notification[@"fireDate"]];
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:fireDate repeats:NO];
    
    NSString *identifier = [RCTConvert NSString:notification[@"identifier"]];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
        }
    }];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(pushNotifications)
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:PushNotificationsStorageKey] ?: @[];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
