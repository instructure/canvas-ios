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
