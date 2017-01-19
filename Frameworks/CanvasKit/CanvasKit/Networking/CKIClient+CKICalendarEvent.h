//
//  CKIClient+CKICalendarEvent.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
