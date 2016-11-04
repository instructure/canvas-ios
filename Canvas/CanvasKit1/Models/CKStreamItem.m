
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
    
    

#import "CKStreamItem.h"
#import "ISO8601DateFormatter.h"
#import "NSDictionary+CKAdditions.h"
#import "ISO8601DateFormatter+CKAdditions.h"

#import "CKStreamAnnouncementItem.h"
#import "CKStreamDiscussionItem.h"
#import "CKStreamMessageItem.h"
#import "CKStreamConversationItem.h"
#import "CKStreamSubmissionItem.h"
#import "NSString+CKAdditions.h"
#import "CKGroup.h"

@implementation CKStreamItem

@synthesize ident, createdAt, updatedAt, title, message, type;
@synthesize contextType, courseId, groupId, course, actionPath;

- (id)initWithInfo:(NSDictionary *)info
{
    CKStreamItemType tempType = [CKStreamItem typeForString:info[@"type"]];
    
    if ([self class] == [CKStreamItem class] && tempType != CKStreamItemTypeDefault) {
        switch (tempType) {
            case CKStreamItemTypeAnnouncement:
                self = [[CKStreamAnnouncementItem alloc] initWithInfo:info];
                break;
            case CKStreamItemTypeDiscussion:
                self = [[CKStreamDiscussionItem alloc] initWithInfo:info];
                break;
            case CKStreamItemTypeMessage:
                self = [[CKStreamMessageItem alloc] initWithInfo:info];
                break;
            case CKStreamItemTypeConversation:
                self = [[CKStreamConversationItem alloc] initWithInfo:info];
                break;
            case CKStreamItemTypeSubmission:
                self = [[CKStreamSubmissionItem alloc] initWithInfo:info];
                break;
            default:
                break;
        }
    }
    else {
        self = [super init];
        if (self) {
            // set all the ivars here
            ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
            
            ident = [info[@"id"] unsignedLongLongValue];
            createdAt = [dateFormatter safeDateFromString:[info objectForKeyCheckingNull:@"created_at"]];
            updatedAt = [dateFormatter safeDateFromString:[info objectForKeyCheckingNull:@"updated_at"]];
            title = [info objectForKeyCheckingNull:@"title"];
            message = [info objectForKeyCheckingNull:@"message"]; 
            type = tempType; // I could do this right after the switch statement, but wanted to keep the ivars together
            
            contextType = [CKStreamItem contextTypeForString:[info objectForKeyCheckingNull:@"context_type"]];
            if (courseId == 0) {
                courseId = [info[@"course_id"] unsignedLongLongValue];
            }
            
            if (groupId == 0) {
                groupId = [info[@"group_id"] unsignedLongLongValue];
            }
        }
    }
    
    return self;
}

- (void)populateActionPath
{
    // override in the subclass if you want something to happen when this item is tapped in a tableview.
}

+ (CKStreamItemType)typeForString:(NSString *)typeString
{
    if ([@"Announcement" isEqualToString:typeString]) {
        return CKStreamItemTypeAnnouncement;
    }
    else if ([@"DiscussionTopic" isEqualToString:typeString]) {
        return CKStreamItemTypeDiscussion;
    }
    else if ([@"Message" isEqualToString:typeString]) {
        return CKStreamItemTypeMessage;
    }
    else if ([@"Conversation" isEqualToString:typeString]) {
        return CKStreamItemTypeConversation;
    }
    else if ([@"Submission" isEqualToString:typeString]) {
        return CKStreamItemTypeSubmission;
    }
    else if ([@"Conference" isEqualToString:typeString]) {
        return CKStreamItemTypeConference;
    }
    else if ([@"Collaboration" isEqualToString:typeString]) {
        return CKStreamItemTypeCollaboration;
    }
    else {
        return CKStreamItemTypeDefault;
    }
}

+ (CKStreamItemContextType)contextTypeForString:(NSString *)contextTypeString
{
    if ([@"Course" isEqualToString:contextTypeString]) {
        return CKStreamItemContextTypeCourse;
    }
    else if ([@"Assignment" isEqualToString:contextTypeString]) {
        return CKStreamItemContextTypeAssignment;
    }
    else if ([@"Group" isEqualToString:contextTypeString]) {
        return CKStreamItemContextTypeGroup;
    }
    else if ([@"Enrollment" isEqualToString:contextTypeString]) {
        return CKStreamItemContextTypeEnrollment;
    }
    else if ([@"Submission" isEqualToString:contextTypeString]) {
        return CKStreamItemContextTypeSubmission;
    }
    else if ([@"CalendarEvent" isEqualToString:contextTypeString]) {
        return CKStreamItemContextTypeCalendarEvent;
    }
    else {
        return CKStreamItemContextTypeNone;
    }
}

- (NSUInteger)hash {
    return self.ident;
}

+ (NSArray *)propertiesToExcludeFromEqualityComparison {
    return @[ @"actionPath"];
}

@end
