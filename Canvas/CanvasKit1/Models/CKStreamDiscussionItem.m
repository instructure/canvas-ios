//
//  CKStreamDiscussionItem.m
//  CanvasKit
//
//  Created by Mark Suman on 8/27/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKStreamDiscussionItem.h"
#import "CKDiscussionTopic.h"
#import "NSDictionary+CKAdditions.h"
#import "CKCourse.h"
#import "CKGroup.h"

@implementation CKStreamDiscussionItem

@synthesize discussionTopicId, totalRootEntries, rootEntries;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super initWithInfo:info];
    if (self) {
        discussionTopicId = [info[@"discussion_topic_id"] unsignedLongLongValue];
        totalRootEntries = [info[@"total_root_discussion_entries"] intValue];
        rootEntries = [info objectForKeyCheckingNull:@"root_discussion_entries"];
    }
    
    return self;
}


- (void)populateActionPath
{
    if (self.actionPath) {
        return;
    }
    
    if (self.courseId) {
        self.actionPath = @[[CKCourse class], @(self.courseId), [CKDiscussionTopic class], @(self.discussionTopicId)];
    } else if (self.groupId) {
        self.actionPath = @[[CKGroup class], @(self.groupId), [CKDiscussionTopic class], @(self.discussionTopicId)];
    }
}

- (NSDictionary *)latestEntry
{
    // TODO: unit test this to make sure it returns the correct one
    NSDictionary *entry = nil;
    
    if ([self.rootEntries count] > 0) {
        entry = [self.rootEntries lastObject];
    }
    
    return entry;
}

@end
