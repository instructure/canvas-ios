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
    
    

#import <CanvasKit1/CanvasKit1.h>

#import "ScheduleItem.h"

@implementation ScheduleItem

@synthesize type, itemObject;
@synthesize ident, eventDate, title, itemDescription, typeDescription;

- (id)initWithObject:(id)anObject
{
    self = [super init];
    if (self) {
        // bar some foos
        itemObject = anObject;
        
        if ([anObject isKindOfClass:[CKAssignment class]]) {
            type = CNVScheduleItemTypeAssignment;
        }
        else if ([anObject isKindOfClass:[CKCalendarItem class]]) {
            type = CNVScheduleItemTypeCalendar;
        }
    }
    
    return self;
}

- (uint64_t)ident
{
    if (CNVScheduleItemTypeAssignment == type) {
        return [(CKAssignment *)itemObject ident];
    }
    else if (CNVScheduleItemTypeCalendar == type) {
        return [(CKCalendarItem *)itemObject typeId];
    }
    return 0;
}

- (NSDate *)eventDate
{
    if (CNVScheduleItemTypeAssignment == type) {
        return [(CKAssignment *)itemObject dueDate];
    }
    else if (CNVScheduleItemTypeCalendar == type) {
        CKCalendarItem *event = (CKCalendarItem *)itemObject;
        if (event.startDate) {
            return event.startDate;
        }
        else if (event.endDate) {
            return event.endDate;
        }
    }
    return nil;
}

- (NSString *)title
{
    if (CNVScheduleItemTypeAssignment == type) {
        return [(CKAssignment *)itemObject name];
    }
    else if (CNVScheduleItemTypeCalendar == type) {
        return [(CKCalendarItem *)itemObject title];
    }
    return nil;
}

- (NSString *)itemDescription
{
    if (CNVScheduleItemTypeAssignment == type) {
        return [(CKAssignment *)itemObject assignmentDescription];
    }
    else if (CNVScheduleItemTypeCalendar == type) {
        CKCalendarItem *calItem = itemObject;
        return calItem.itemDescription;
    }
    return nil;
}

- (NSString *)typeDescription
{
    if (CNVScheduleItemTypeAssignment == type) {
        CKAssignmentType assignmentType = [(CKAssignment *)itemObject type];
        NSString *typeDescriptionString = nil;
        switch (assignmentType) {
            case CKAssignmentTypeDiscussion:
                typeDescriptionString = NSLocalizedString(@"Graded Discussion", @"Label for a discussion");
                break;
            case CKAssignmentTypeQuiz:
                typeDescriptionString = NSLocalizedString(@"Quiz", @"A short test taken by students");
                break;
            case CKAssignmentTypeAttendance:
                typeDescriptionString = NSLocalizedString(@"Attendance", @"Label for a discussion");
                break;
            default:
                typeDescriptionString = NSLocalizedString(@"Assignment", @"Label for an assignment");
                break;
        }
        
        return typeDescriptionString;
    }
    else if (CNVScheduleItemTypeCalendar == type) {
        return NSLocalizedString(@"Event", @"Label for a calendar event");
    }
    
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<(ScheduleItem %p) eventDate: %@, title: %@>", self, self.eventDate, self.title];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[ScheduleItem class]] == NO) {
        return NO;
    }
    return [[(ScheduleItem *)object itemObject] isEqual:[self itemObject]];
}

@end
