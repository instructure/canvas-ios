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

#import "CKIModel.h"
#import "CKIUser.h"

@interface CKICalendarEvent : CKIModel

/**
 The title of the calendar event
 */
@property (nonatomic, copy) NSString *title;

/**
 The start timestamp of the event
 */
@property (nonatomic, strong) NSDate *startAt;

/**
 The end timestamp of the event
 */
@property (nonatomic, strong) NSDate *endAt;

/**
 The HTML description of the event
 */
@property (nonatomic, copy) NSString *description;

/**
 The location name of the event
 */
@property (nonatomic, copy) NSString *locationName;

/**
 The address where the event is taking place
 */
@property (nonatomic, copy) NSString *locationAddress;

/**
 The context code of the calendar this event belongs to (course, user, or group)
 */
@property (nonatomic, copy) NSString *contextCode;

/**
 If specified, it indicates which calendar this event should be displayed on.
 For example, a section-level event would have the course's context code here,
 while the section's context code would be returned above
 */
//@property (nonatomic, copy) NSString *effectiveContextCode;

/**
 Current state of the event ('active', 'locked', or 'deleted')
 'locked' -> indicates that the start_at/end_at cannot be changed (though the event could be deleted). 
             Normally only reservations or time slots with reservations are locked (see the Appointment Groups API api.instructure.com)
 */
@property (nonatomic, copy) NSString *workflowState;

/**
 Whether this event should be displayed on the calendar. Only true for course-level events with section-level child events.
 */
@property (nonatomic) BOOL hidden;

/**
 Normally null. If this is a reservation (see the Appointment Groups API api.instructure.com), the id will indicate the time
 slot it is for. If this is a section-level event, this will be the course-level parent event.
 */
@property (nonatomic, copy) NSString *parentEventID;

/**
 If this is a time slot this will be a list of any reservations. If this is a course-level event, this will be a list
 of section-level events (if any)
 */
@property (nonatomic, strong) NSArray *childEvents;

/**
 The number of |childEvents|
 */
@property (nonatomic) NSInteger childEventsCount;

/**
 URL for this calendar event (to update, delete, etc.)
 */
@property (nonatomic, strong) NSURL *url;

/**
 URL for a user to view this event
 */
@property (nonatomic, strong) NSURL *htmlURL;

/**
 The date of this event
 */
@property (nonatomic, strong) NSDate *allDayDate;

/**
 Boolean indicating whether this is an all-day event (midnight to midnight)
 */
@property (nonatomic, getter = isAllDay) BOOL allDay;

/**
 When the calendar event was created
 */
@property (nonatomic, strong) NSDate *createdAt;

/**
 When the calendar event was last updated
 */
@property (nonatomic, strong) NSDate *updatedAt;

/**
 The id of the appointment group
 */
@property (nonatomic, copy) NSString *appointmentGroupID;

/**
 The API URL of the appointment group
 */
@property (nonatomic, strong) NSURL *appointmentGroupURL;

/**
 If the event is a reservation, this boolean indicates whether it is the current user's reservation, or someone else's
 */
@property (nonatomic, getter = isOwnReservation) BOOL ownReservation;

/**
 If the event is a time slot, the API URL for reserving it
 */
@property (nonatomic, strong) NSURL *reserveURL;

/**
 If the event is a time slot, a boolean indicating whether the user has already made a reservation for it
 */
@property (nonatomic, getter = isReserved) BOOL reserved;

/**
 If the event is a time slot, this is the participant limit
 */
//@property (nonatomic) NSInteger *participantsPerAppointment;

/**
 If the event is a time slot and it has a participant limit, an integer indicating how many slots are available
 */
//@property (nonatomic) NSInteger *availableSlots;

/**
 If the event is a user-level reservation, this will contain the user participant JSON (refer to the Users API)
 */
@property (nonatomic, strong) CKIUser *user;

/**
 If the event is a group-level reservation, this will contain the group participant JSON (refer to the Groups API)
 */
//@property (nonatomic, strong) CKIGroup *group;

@end
