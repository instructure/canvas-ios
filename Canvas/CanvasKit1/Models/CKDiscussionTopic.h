//
//  CKDiscussionTopic.h
//  CanvasKit
//
//  Created by Mark Suman on 11/4/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"
#import "CKContentLock.h"

@class CKAssignment, CKStudent, CKContextInfo;

typedef enum {
    CKDiscussionTopicTypeSideComment,
    CKDiscussionTopicTypeThreaded
} CKDiscussionTopicType;

@interface CKDiscussionTopic : CKModelObject

@property uint64_t ident;
@property (nonatomic, strong) NSURL *liveURL;

@property (copy) NSString *title;
@property (copy) NSString *message;
@property (copy) NSString *creatorName;
@property (copy) NSDate *postDate;
@property (copy) NSDate *lastReplyDate;
@property (nonatomic, weak) CKAssignment *assignment;
@property uint64_t assignmentIdent;
@property uint64_t groupCategoryID;
@property (strong) NSArray *discussionEntries;
@property (strong) NSArray *topicChildren;
@property (assign) BOOL hasMoreEntries;
@property (copy) CKContextInfo *contextInfo;
@property CKDiscussionTopicType type;
@property (nonatomic) BOOL canAddAttachments;
@property (assign) int unreadChildren;
@property (assign) BOOL requiresInitialPost;
@property (assign) BOOL isLocked;
@property (readonly) CKContentLock *contentLock;
@property (assign) BOOL allowRating;
@property (assign) BOOL onlyGradersCanRate;
@property (strong, nonatomic, readonly) NSMutableDictionary *attachments;


- (id)initWithInfo:(NSDictionary *)info andAssignment:(CKAssignment *)anAssignment;

- (void)updateWithInfo:(NSDictionary *)info;
- (NSArray *)entriesForStudent:(CKStudent *)student;

- (void)recalculateUnreadChildren;

@end
