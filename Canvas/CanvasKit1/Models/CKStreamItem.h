//
//  CKStreamItem.h
//  CanvasKit
//
//  Created by Mark Suman on 8/11/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
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
