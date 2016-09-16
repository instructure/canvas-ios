//
//  CKContextInfo.m
//  CanvasKit
//
//  Created by BJ Homer on 10/3/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
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
    return self.contextType ^ self.ident;
}

@end
