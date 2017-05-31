//
//  PushNotifications.m
//  Teacher
//
//  Created by Matthew Sessions on 5/24/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import "PushNotifications.h"
#import <React/RCTConvert.h>

@import UserNotifications;

@implementation PushNotifications

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(requestPermissions)
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    
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

@end
