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
    
    

#import "CBILocalNotificationHandler.h"
#import "iCanvasConstants.h"
@import CanvasKit;
@import CanvasKeymaster;

static NSInteger const CBILocalNotificationNumberSecondsInMinute = 60;
static NSInteger const CBILocalNotificationNumberMinutesInHour = 60;
static NSInteger const CBILocalNotificationNumberMinutesInDay = (CBILocalNotificationNumberMinutesInHour*24);

@implementation CBILocalNotificationHandler

+ (instancetype) sharedInstance {
    static CBILocalNotificationHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)scheduleLocalNotificationForAssignmentDue:(CKIAssignment *)assignment offsetInMinutes:(NSInteger)minutes
{
    NSDate *reminderDate = [assignment.dueAt dateByAddingTimeInterval:-CBILocalNotificationNumberSecondsInMinute * minutes];
    
    [self scheduleLocalNotificationWithBody:[NSString stringWithFormat:NSLocalizedString(@"%@ is due in %@", @"local notification countdown alert") , assignment.name, [self dueDateFromMinuteOffset:minutes]] fireDate:reminderDate userInfo:[self userInfoDictionaryForAssignment:assignment]];
}

- (void)scheduleLocalNotificationWithBody:(NSString *)body fireDate:(NSDate *)fireDate userInfo:(NSDictionary *)userInfo {
    // Schedule the notification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    localNotification.alertBody = body;
    localNotification.alertAction = @"View";
    localNotification.userInfo = userInfo;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


- (BOOL)localNotificationExists:(NSString *)identifier {
    UILocalNotification *returnVal = [self localNotificationWithAssignmentID:identifier];
    return (returnVal != nil);
}

- (UILocalNotification *)localNotificationWithAssignmentID:(NSString *)identifier {
    __block UILocalNotification *returnVal = nil;
    [[[UIApplication sharedApplication] scheduledLocalNotifications] enumerateObjectsUsingBlock:^(UILocalNotification *localNotification, NSUInteger idx, BOOL *stop) {
        if ([localNotification.userInfo[CBILocalNotificationAssignmentIDKey] isEqualToString:identifier]) {
            returnVal = localNotification;
        }
    }];
    
    return returnVal;
}

- (void)removeLocalNotification:(NSString *)identifier {
    [[UIApplication sharedApplication] cancelLocalNotification:[self localNotificationWithAssignmentID:identifier]];
}

- (NSString *)dueDateFromMinuteOffset:(NSUInteger)minutes {
    // return minutes string if less than 60
    if (minutes <= 1) {
        return [NSString stringWithFormat:NSLocalizedString(@"%tu minute", @"offset for less than one minute"), minutes];
    }
    
    if (minutes < CBILocalNotificationNumberMinutesInHour) {
        return [NSString stringWithFormat:NSLocalizedString(@"%tu minutes", @"offset for under an hour"), minutes];
    }
    
    // return hours string if less than 24
    NSUInteger numHours = minutes/CBILocalNotificationNumberMinutesInHour;
    if (numHours <= 1) {
        return [NSString stringWithFormat:NSLocalizedString(@"%tu hour", @"offset for an hour"), numHours];
    }
    
    if (minutes < CBILocalNotificationNumberMinutesInDay) {
        return [NSString stringWithFormat:NSLocalizedString(@"%tu hours", @"offset for number of hours"), numHours];
    }
    
    NSUInteger numDays = minutes/CBILocalNotificationNumberMinutesInDay;
    if (numDays <= 1) {
        return [NSString stringWithFormat:NSLocalizedString(@"%tu day", @"offset for one day"), numDays];
    }
    
    return [NSString stringWithFormat:NSLocalizedString(@"%tu days", @"offset for number of days"), numDays];
}

- (NSString *)canvasURLForAssignment:(CKIAssignment *)assignment {
    return [NSString stringWithFormat:@"canvas-courses://%@/%@", [[[CKIClient currentClient] baseURL] host], assignment.path];
}

- (NSDictionary *)userInfoDictionaryForAssignment:(CKIAssignment *)assignment {
    return @{
             CBILocalNotificationAssignmentIDKey : assignment.id,
             CBILocalNotificationAssignmentURLKey : [self canvasURLForAssignment:assignment]
             };
}

@end
