//
//  CKIClient+CKIDiscussionTopic.h
//  CanvasKit
//
//  Created by derrick on 12/13/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKICourse, CKIDiscussionTopic;

@interface CKIClient (CKIDiscussionTopic)
- (RACSignal *)fetchDiscussionTopicsForContext:(id<CKIContext>)context;
- (RACSignal *)fetchDiscussionTopicForContext:(id<CKIContext>)context topicID:(NSString *)topicID;
- (RACSignal *)fetchAnnouncementsForContext:(id<CKIContext>)context;

- (RACSignal *)markTopicAsRead:(CKIDiscussionTopic *)topic;
@end
