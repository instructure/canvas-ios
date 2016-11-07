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
    
    

#import "CKConversationRecipient.h"
#import "CKEnrollment.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKConversationRecipient {
    uint64_t _cachedIdent;
}
@synthesize name;
@synthesize type;
@synthesize avatarURL;
@synthesize identString;
@synthesize itemCount;
@synthesize userCount;
@synthesize commonGroups;
@synthesize commonCourses;

//{
//    "avatar_url" = "https://secure.gravatar.com/avatar/35c8dfd8c8d53ccb8882e474c72424cb?s=50&d=https%3A%2F%2Fcanvas.instructure.com%2Fimages%2Fmessages%2Favatar-50.png";
//    "common_courses" =     
//     {
//        0 =         (
//                     StudentEnrollment
//                     );
//    };
//    "common_groups" =     {
//    };
//    id = 247686;
//    name = "10312023@uvlink.uvu.edu";
//}

//{
//    "avatar_url" = "https://canvas.instructure.com/images/messages/avatar-group-50.png";
//    id = "course_24219";
//    name = "Beginning iOS Development";
//    type = context;
//    "user_count" = 19;
//},

static CKEnrollmentType enrollmentTypeForResultArray(NSArray *results) {
    CKEnrollmentType type = 0;
    for (NSString *enrollment in results) {
        if ([enrollment isEqualToString:@"StudentEnrollment"]) {
            type |= CKEnrollmentTypeStudent;
        }
        else if ([enrollment isEqualToString:@"TeacherEnrollment"]) {
            type |= CKEnrollmentTypeTeacher;
        }
        else if ([enrollment isEqualToString:@"TaEnrollment"]) {
            type |= CKEnrollmentTypeTA;
        }
        else if ([enrollment isEqualToString:@"ObserverEnrollment"]) {
            type |= CKEnrollmentTypeObserver;
        }
        else if ([enrollment isEqualToString:@"Member"]) {
            type |= CKEnrollmentTypeGroupMember;
        }
        else {
            NSLog(@"Unknown enrollment type: %@", enrollment);
        }
    }
    return type;
}

- (id)initWithInfo:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = [dictionary objectForKeyCheckingNull:@"name"];
        self.containingContextName = [dictionary objectForKeyCheckingNull:@"context_name"];
        
        NSString *avatarURLString = [dictionary objectForKeyCheckingNull:@"avatar_url"];
        if (avatarURLString) {
            self.avatarURL = [NSURL URLWithString:avatarURLString];
        }
        self.identString = [[dictionary objectForKeyCheckingNull:@"id"] description];
        if (identString) {
            _cachedIdent = strtoull(identString.UTF8String, NULL, 10);
        }
        
        
        if ([[dictionary objectForKeyCheckingNull:@"type"] isEqualToString:@"context"]) {
            self.type = CKRecipientTypeContext;
        }
        else {
            self.type = CKRecipientTypeUser;
        }
        
        self.userCount = [[dictionary objectForKeyCheckingNull:@"user_count"] intValue];
        self.itemCount = [[dictionary objectForKeyCheckingNull:@"item_count"] intValue];
        
        if (self.type == CKRecipientTypeUser) {
            self.userCount = 1;
        }
        
        
        NSMutableDictionary *tmpCommonCourses = [NSMutableDictionary dictionary];
        NSDictionary *commonCoursesInput = [dictionary objectForKeyCheckingNull:@"common_courses"];
        [commonCoursesInput enumerateKeysAndObjectsUsingBlock:^(NSNumber *courseID, NSArray *enrollments, BOOL *stop) {
            if (courseID.unsignedLongLongValue == 0) {
                return;
            }
            CKEnrollmentType enrollmentType = enrollmentTypeForResultArray(enrollments);
            tmpCommonCourses[courseID] = @(enrollmentType);
        }];
        self.commonCourses = [tmpCommonCourses copy];
        
        NSMutableDictionary *tmpCommonGroups = [NSMutableDictionary dictionary];
        NSDictionary *commonGroupsInput = [dictionary objectForKeyCheckingNull:@"common_groups"];
        [commonGroupsInput enumerateKeysAndObjectsUsingBlock:^(NSNumber *groupID, NSArray *enrollments, BOOL *stop) {
            if (groupID.unsignedLongLongValue == 0) {
                return;
            }
            CKEnrollmentType enrollmentType = enrollmentTypeForResultArray(enrollments);
            tmpCommonGroups[groupID] = @(enrollmentType);
        }];
        self.commonGroups = [tmpCommonGroups copy];
        
    }
    return self;
}

- (uint64_t)ident {
    return _cachedIdent;
}

- (NSUInteger)hash {
    return [identString hash];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<CKConversationRecipient %p: %@ (%@)>", self, self.identString, self.name];
}

+ (NSArray *)propertiesToExcludeFromEqualityComparison {
    // These are all properties that are sometimes not included in the response, depending on whether
    // we're searching or looking at an existing conversation.
    return @[@"commonCourses", @"commonGroups", @"avatarURL"];
}

@end
