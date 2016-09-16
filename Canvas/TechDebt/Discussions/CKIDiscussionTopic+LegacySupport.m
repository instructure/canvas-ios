//
//  CKIDiscussionTopic+LegacySupport.m
//  iCanvas
//
//  Created by derrick on 1/7/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIDiscussionTopic+LegacySupport.h"
#import <CanvasKit1/CanvasKit1.h>

@implementation CKIDiscussionTopic (LegacySupport)
+ (instancetype)discussionTopicFromLegacyDiscussionTopic:(CKDiscussionTopic *)topic
{
    CKIDiscussionTopic *newOne;
    if (topic.contextInfo.contextType == CKContextTypeGroup){
        CKIGroup * group = [CKIGroup modelWithID:[@(topic.contextInfo.ident) description]];
        newOne = [CKIDiscussionTopic modelWithID:[@(topic.ident) description] context:group];
    } else {
        CKICourse * course = [CKICourse modelWithID:[@(topic.contextInfo.ident) description]];
        newOne = [CKIDiscussionTopic modelWithID:[@(topic.ident) description] context:course];
    }
    
    newOne.messageHTML = topic.message;
    newOne.title = topic.title;
    newOne.postedAt = topic.postDate;
    newOne.lastReplyAt = topic.lastReplyDate;
    
    // only adding a few for right now pretty confident that's all that is needed.
    return newOne;
}
@end
