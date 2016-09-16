//
//  CKActivityStreamSummary.h
//  CanvasKit
//
//  Created by nlambson on 6/11/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKModelObject.h"

@interface CKActivityStreamSummary : NSObject

//see original API endpoint for types: https://canvas.instructure.com/doc/api/users.html#method.users.activity_stream
@property (readonly) NSInteger discussionTopicCount;
@property (readonly) NSInteger discussionTopicUnreadCount;

@property (readonly) NSInteger announcementCount;
@property (readonly) NSInteger announcementUnreadCount;

@property (readonly) NSInteger conversationCount;
@property (readonly) NSInteger conversationUnreadCount;

@property (readonly) NSInteger messageCount;
@property (readonly) NSInteger messageUnreadCount;

@property (readonly) NSInteger submissionCount;
@property (readonly) NSInteger submissionUnreadCount;

@property (readonly) NSInteger conferenceCount;
@property (readonly) NSInteger conferenceUnreadCount;

@property (readonly) NSInteger collaborationCount;
@property (readonly) NSInteger collaborationUnreadCount;

@property (readonly) NSInteger collectionItemCount;
@property (readonly) NSInteger collectionItemUnreadCount;

@property (readonly) NSInteger count;
@property (readonly) NSInteger unreadCount;

- (id)initWithInfo:(NSArray *)info;
+ (id)activityStreamSummary:(NSArray *)info;

- (NSInteger)totalCount;
- (NSInteger)totalUnreadCount;

@end
