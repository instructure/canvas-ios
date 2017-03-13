//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
