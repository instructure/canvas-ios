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

typedef enum : NSUInteger {
    CKEnrollmentTypeUnknown     = 0,
    CKEnrollmentTypeStudent     = 1 << 0,
    CKEnrollmentTypeTeacher     = 1 << 1,
    CKEnrollmentTypeTA          = 1 << 2,
    CKEnrollmentTypeObserver    = 1 << 3,
    CKEnrollmentTypeGroupMember = 1 << 4,
    CKEnrollmentTypeDesigner    = 1 << 5,
    CKEnrollmentTypeStudentView = 1 << 6
} CKEnrollmentType;

@interface CKEnrollment : CKModelObject

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, assign) uint64_t courseId;
@property (nonatomic, assign) uint64_t courseSectionId;
@property (nonatomic, copy) NSString *enrollmentState;
@property (nonatomic, assign) BOOL limitPrivilegesToCourseSection;
@property (nonatomic, assign) uint64_t rootAccountId;
@property (nonatomic, readonly, copy) NSString *typeString;
@property (nonatomic, readonly, copy) NSString *shortName;
@property (nonatomic) CKEnrollmentType type;
@property (nonatomic, assign) uint64_t userId;
@property (nonatomic, assign) uint64_t associatedUserId;
@property (nonatomic, copy) NSURL *htmlURL;
@property (nonatomic, copy) NSURL *gradeURL;

- (id)initWithInfo:(NSDictionary *)info;

- (void)updateWithInfo:(NSDictionary *)info;

+ (NSString *)simpleEnrollmentStringForType:(CKEnrollmentType)type;

@end
