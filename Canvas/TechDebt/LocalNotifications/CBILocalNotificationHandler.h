//
//  CBILocalNotificationHandler.h
//  iCanvas
//
//  Created by Brandon Pluim on 8/18/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKIAssignment;

@interface CBILocalNotificationHandler : NSObject

+ (instancetype) sharedInstance;

- (void)scheduleLocalNotificationForAssignmentDue:(CKIAssignment *)assignment offsetInMinutes:(NSInteger)minutes;
- (BOOL)localNotificationExists:(NSString *)identifier;
- (void)removeLocalNotification:(NSString *)identifier;

@end
