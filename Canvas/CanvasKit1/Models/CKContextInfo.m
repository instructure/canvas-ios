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
    
    

#import "CKContextInfo.h"
#import "CKCourse.h"
#import "CKGroup.h"
#import "CKUser.h"

@implementation CKContextInfo

+ (CKContextInfo *)contextInfoFromCourse:(CKCourse *)course {
    CKContextInfo *info = [CKContextInfo new];
    info->_ident = course.ident;
    info->_contextType = CKContextTypeCourse;
    return info;
}

+ (CKContextInfo *)contextInfoFromCourseIdent:(uint64_t)courseIdent {
    CKContextInfo *info = [CKContextInfo new];
    info->_ident = courseIdent;
    info->_contextType = CKContextTypeCourse;
    return info;
}

+ (CKContextInfo *)contextInfoFromGroup:(CKGroup *)group {
    CKContextInfo *info = [CKContextInfo new];
    info->_ident = group.ident;
    info->_contextType = CKContextTypeGroup;
    return info;
}


+ (CKContextInfo *)contextInfoFromGroupIdent:(uint64_t)groupIdent {
    CKContextInfo *info = [CKContextInfo new];
    info->_ident = groupIdent;
    info->_contextType = CKContextTypeGroup;
    return info;
}

+ (CKContextInfo *)contextInfoFromUser:(CKUser *)user {
    CKContextInfo *info = [CKContextInfo new];
    info->_ident = user.ident;
    info->_contextType = CKContextTypeUser;
    return info;
}

+ (CKContextInfo *)contextInfoFromUserIdent:(uint64_t)userIdent {
    CKContextInfo *info = [CKContextInfo new];
    info->_ident = userIdent;
    info->_contextType = CKContextTypeUser;
    return info;
}

- (id)initWithContextType:(CKContextType)type ident:(uint64_t)ident {
    self = [super init];
    if (self) {
        _ident = ident;
        _contextType = type;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CKContextInfo *new = [[self class] new];
    new->_contextType = self.contextType;
    new->_ident = self.ident;
    return new;
}

- (BOOL)isEqual:(CKContextInfo *)other {
    if ([other isKindOfClass:[CKContextInfo class]]) {
        return NO;
    }
    return self.ident == other.ident && self.contextType == other.contextType;
}

- (NSUInteger)hash {
    return (NSUInteger)(self.contextType ^ self.ident);
}

@end
