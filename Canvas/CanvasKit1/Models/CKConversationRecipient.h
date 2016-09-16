//
//  CKConversationRecipient.h
//  CanvasKit
//
//  Created by BJ Homer on 11/1/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
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
