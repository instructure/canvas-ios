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

#import "CKIClient.h"

@class RACSignal;
@class CKICourse;

@interface CKIClient (CKICalendarEvent)

/**
 Fetches all calendar events for the context
 */
- (RACSignal *)fetchCalendarEventsForContext:(id<CKIContext>)context;

/**
 Fetches only today's calendar events for the current user
 */
- (RACSignal *)fetchCalendarEventsForToday;

/**
 Fetches the calendar events between the start date and the end date for the current user
 
 @param startDate the earlist possible date for a returned calendar event
 @param endDate the latest possible date for a returned calendar event
 */
- (RACSignal *)fetchCalendarEventsFrom:(NSDate *)startDate to:(NSDate *)endDate;

/**
 Fetches all of the calendar events for the current user
 */
- (RACSignal *)fetchCalendarEvents;

@end
