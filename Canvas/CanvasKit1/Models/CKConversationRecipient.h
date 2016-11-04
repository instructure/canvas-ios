
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
    
    

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

typedef enum {
    CKRecipientTypeUser = 1,
    CKRecipientTypeContext
} CKConversationRecipientType;

@interface CKConversationRecipient : CKModelObject

- (id)initWithInfo:(NSDictionary *)dictionary;

@property(copy) NSString *name;
@property(assign) CKConversationRecipientType type;
@property(copy) NSString *containingContextName; // Only set for groups, this is the name of the course
@property(copy) NSURL *avatarURL;
@property(copy) NSString *identString;  // May be "2" or "course_24626"
@property(assign, readonly) uint64_t ident;  // 0 if this is a context

@property(assign) int itemCount; // 1 if this is a user
@property(assign) int userCount;

// Only for users:
@property(copy) NSArray *commonGroups;  // NSDictionary ( NSNumber(courseID) -> NSNumber(CKEnrollmentType) )
@property(copy) NSArray *commonCourses; // NSDictionary ( NSNumber(courseID) -> NSNumber(CKEnrollmentType) )

@end
