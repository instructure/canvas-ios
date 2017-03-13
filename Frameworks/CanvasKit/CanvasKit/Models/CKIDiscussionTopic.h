//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CKIModel.h"

typedef NS_ENUM(NSInteger, CKIDiscussionTopicType) {
    CKIDiscussionTopicTypeSideComment,
    CKIDiscussionTopicTypeThreaded
};

typedef NS_ENUM(NSInteger, CKIDiscussionTopicSubscriptionHold) {
    CKIDiscussionTopicSubscriptionHoldNone,
    CKIDiscussionTopicSubscriptionHoldInitialPostRequired,
    CKIDiscussionTopicSubscriptionHoldNotInGroupSet,
    CKIDiscussionTopicSubscriptionHoldNotInGroup,
    CKIDiscussionTopicSubscriptionHoldTopicIsAnnouncement,
};

@class CKILockInfo;

@interface CKIDiscussionTopic : CKIModel
/**
 The topic title.
 */
@property (nonatomic, copy) NSString *title;

/**
 The HTML content of the message body.
 */
@property (nonatomic, copy) NSString *messageHTML;
/**
 The URL to the discussion topic in canvas.
 */
@property (nonatomic, copy) NSURL *htmlURL;
/**
 The datetime the topic was posted. If it is null it hasn't been
 posted yet. (see delayed_post_at)
 */
@property (nonatomic) NSDate *postedAt;
/**
 The datetime for when the last reply was in the topic.
 */
@property (nonatomic) NSDate *lastReplyAt;
/**
 If true then a user may not respond to other replies until that user
 has made an initial reply. Defaults to false.
 */
@property (nonatomic) BOOL requireInitialPost;
/**
 Whether or not posts in this topic are visible to the user.
 */
@property (nonatomic) BOOL userCanSeePosts;
/**
 The count of entries in the topic.
 */
@property (nonatomic) NSInteger subentryCount;
/**
 The read_state of the topic for the current user, "read" or "unread".
 */
@property (nonatomic) BOOL isRead;
/**
 The count of unread entries of this topic for the current user.
 */
@property (nonatomic) NSInteger unreadCount;
/**
 Whether or not the current user is subscribed to this topic.
 */
@property (nonatomic) BOOL isSubscribed;
/**
 (Optional) Why the user cannot subscribe to this topic. Only one reason
 will be returned even if multiple apply. Can be one of:
 'initial_post_required': The user must post a reply first
 'not_in_group_set': The user is not in the group set for this graded group discussion
 'not_in_group': The user is not in this topic's group
 'topic_is_announcement': This topic is an announcement
 */
@property (nonatomic) CKIDiscussionTopicSubscriptionHold subscriptionHold;
/**
 The unique identifier of the assignment if the topic is for grading, otherwise null.
 */
@property (nonatomic, copy) NSString *assignmentID;
/**
 The datetime to publish the topic (if not right away).
 */
@property (nonatomic) NSDate *delayedPostAt;
/**
 Whether this discussion topic is published (true) or draft state (false)
 */
@property (nonatomic) BOOL isPublished;
/**
 The datetime to lock the topic (if ever).
 */
@property (nonatomic) NSDate *lockAt;
/**
 whether or not this is locked for students to see.
 */
@property (nonatomic) BOOL isLocked;
/**
 whether or not the discussion has been "pinned" by an instructor
 */
@property (nonatomic) BOOL isPinned;
/**
 Whether or not this is locked for the user.
 */
@property (nonatomic) BOOL isLockedForUser;
/**
 (Optional) Information for the user about the lock. Present when locked_for_user is true.
 */
@property (nonatomic) CKILockInfo *lockInfo;
/**
 (Optional) An explanation of why this is locked for the user. Present when locked_for_user is true.
 */
@property (nonatomic, copy) NSString *lockExplanation;
/**
 The username of the topic creator.
 */
@property (nonatomic, copy) NSString *userName;
/**
 An array of topic_ids for the group discussions the user is a part of.
 */
@property (nonatomic, copy) NSArray *childrenTopicIDs;
/**
 If the topic is for grading and a group assignment this will
 point to the original topic in the course.
 */
@property (nonatomic, copy) NSString *rootTopicID;
/**
 If the topic is a podcast topic this is the feed url for the current user.
 */
@property (nonatomic) NSURL *podcastURL;
/**
 The type of discussion. Values are 'side_comment', for discussions
 that only allow one level of nested comments, and 'threaded' for
 fully threaded discussions.
 */
@property (nonatomic) CKIDiscussionTopicType type;

/**
 Array of file attachments.
 */
@property (nonatomic, copy) NSArray *attachments;

/**
 The current user's permissions on this topic.
 */
@property (nonatomic) BOOL canAttachPermission;

/**
 The position of this discussion. Position is only given if it's a "pinned" discussion.
 */
@property (nonatomic) NSInteger position;

@end
