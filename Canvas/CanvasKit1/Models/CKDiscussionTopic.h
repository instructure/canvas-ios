//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
