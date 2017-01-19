//
//  CKIActivityStreamDiscussionTopicItem.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIActivityStreamItem.h"

/**
 Activity stream item for both discussions and annoucements.
 */

@interface CKIActivityStreamDiscussionTopicItem : CKIActivityStreamItem

/**
 The number of root discussion entries.
 */
@property (nonatomic) NSInteger totalRootDiscussionEntries;

/**
 An initial post is required.
 */
@property (nonatomic) BOOL requireInitialPost;

/**
 The current user has posted to the discussion.
 */
@property (nonatomic) BOOL userHasPosted;

/**
 The ID of the discussion topic.
 */
@property (nonatomic, copy) NSString * discussionTopicID;

@end
