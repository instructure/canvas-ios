//
//  CKIDiscussionTopic+LegacySupport.h
//  iCanvas
//
//  Created by derrick on 1/7/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

@import CanvasKit;

@class CKDiscussionTopic;

@interface CKIDiscussionTopic (LegacySupport)
+ (instancetype)discussionTopicFromLegacyDiscussionTopic:(CKDiscussionTopic *)topic;
@end
