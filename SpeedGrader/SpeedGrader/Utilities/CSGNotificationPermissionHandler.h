//
//  CSGNotificationPermissionHandler.h
//  SpeedGrader
//
//  Created by Nathan Lambson on 11/10/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSGNotificationPermissionHandler : NSObject

+ (void)checkPermissions;
+ (bool)canSendNotifications;

@end
