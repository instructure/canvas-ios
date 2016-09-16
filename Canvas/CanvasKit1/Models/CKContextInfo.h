//
//  CKContextInfo.h
//  CanvasKit
//
//  Created by BJ Homer on 10/3/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCommonTypes.h"

@class CKCourse, CKGroup, CKUser;

@interface CKContextInfo : NSObject <NSCopying>

+ (CKContextInfo *)contextInfoFromCourse:(CKCourse *)course;
+ (CKContextInfo *)contextInfoFromCourseIdent:(uint64_t)courseIdent;
+ (CKContextInfo *)contextInfoFromGroup:(CKGroup *)group;
+ (CKContextInfo *)contextInfoFromGroupIdent:(uint64_t)groupIdent;
+ (CKContextInfo *)contextInfoFromUser:(CKUser *)user;
+ (CKContextInfo *)contextInfoFromUserIdent:(uint64_t)userIdent;

- (id)initWithContextType:(CKContextType)type ident:(uint64_t)ident;

@property (readonly) CKContextType contextType;
@property (readonly) uint64_t ident;

@end
