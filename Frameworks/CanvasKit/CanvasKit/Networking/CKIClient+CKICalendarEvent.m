//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

@import ReactiveObjC;

#import "CKIClient+CKICalendarEvent.h"
#import "CKICalendarEvent.h"
#import "CKICourse.h"
#import "CKIGroup.h"

@implementation CKIClient (CKICalendarEvent)

- (RACSignal *)fetchCalendarEventsForContext:(id<CKIContext>)context
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"calendar_events"];
    
    NSString *contextCode = @"";
    if ([context isKindOfClass:[CKICourse class]]){
        contextCode = [NSString stringWithFormat:@"course_%@", ((CKICourse *)context).id];
    } else if ([context isKindOfClass:[CKIGroup class]]){
        contextCode = [NSString stringWithFormat:@"groups_%@", ((CKIGroup *)context).id];
    } else if ([context isKindOfClass:[CKIUser class]]) {
        contextCode = [NSString stringWithFormat:@"users_%@", ((CKIUser *)context).id];
    }
    
    NSDictionary *params = @{@"type": @"event",
                             @"context_codes": @[contextCode],
                             @"start_date": @"1900-01-01",
                             @"end_date": @"2099-12-31"};
    return [self fetchResponseAtPath:path parameters:params modelClass:[CKICalendarEvent class] context:nil];
}

- (RACSignal *)fetchCalendarEventsForToday
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"calendar_events"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKICalendarEvent class] context:nil];
}

- (RACSignal *)fetchCalendarEventsFrom:(NSDate *)startDate to:(NSDate *)endDate
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"calendar_events"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-mm-dd"];
    NSDictionary *params = @{@"start_date": [dateFormatter stringFromDate:startDate], @"end_date": [dateFormatter stringFromDate:endDate]};
    return [self fetchResponseAtPath:path parameters:params modelClass:[CKICalendarEvent class] context:nil];
}

- (RACSignal *)fetchCalendarEvents
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"calendar_events"];
    NSDictionary *params = @{@"all_events": @"true"};
    return [self fetchResponseAtPath:path parameters:params modelClass:[CKICalendarEvent class] context:nil];
}

@end
