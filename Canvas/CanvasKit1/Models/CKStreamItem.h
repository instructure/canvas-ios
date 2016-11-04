
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
@class CKContextInfo;

typedef enum {
    CKStreamItemTypeDefault,
    CKStreamItemTypeAnnouncement,
    CKStreamItemTypeDiscussion,
    CKStreamItemTypeMessage,
    CKStreamItemTypeConversation,
    CKStreamItemTypeSubmission,
    CKStreamItemTypeConference,
    CKStreamItemTypeCollaboration,
} CKStreamItemType;

typedef enum {
    CKStreamItemContextTypeNone,
    CKStreamItemContextTypeCourse,
    CKStreamItemContextTypeAssignment,
    CKStreamItemContextTypeGroup,
    CKStreamItemContextTypeEnrollment,
    CKStreamItemContextTypeSubmission,
    CKStreamItemContextTypeCalendarEvent
}CKStreamItemContextType;

@class CKCourse, CKGroup;

@interface CKStreamItem : CKModelObject

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) CKStreamItemType type;

// Context information
@property (nonatomic, assign) CKStreamItemContextType contextType;
@property (copy) CKContextInfo *context;
@property (nonatomic, assign) uint64_t courseId;
@property (nonatomic, assign) uint64_t groupId;
@property (nonatomic, strong) CKCourse *course;
@property (nonatomic, strong) CKGroup *group;
@property (nonatomic, strong) NSArray *actionPath;

- (id)initWithInfo:(NSDictionary *)info;
- (void)populateActionPath;

+ (CKStreamItemType)typeForString:(NSString *)typeString;
+ (CKStreamItemContextType)contextTypeForString:(NSString *)contextTypeString;

@end
