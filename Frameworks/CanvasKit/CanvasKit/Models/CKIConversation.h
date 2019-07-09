//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

#import "CKIModel.h"

typedef NS_ENUM(NSInteger, CKIConversationWorkflowState) {
    CKIConversationWorkflowStateRead,
    CKIConversationWorkflowStateUnread,
    CKIConversationWorkflowStateArchived
};

@interface CKIConversation : CKIModel

/**
 The subject of the conversation
 */
@property (nonatomic, copy) NSString *subject;

/**
 The state of the conversation
 @see CKIConversationWorkflowState
 */
@property (nonatomic) CKIConversationWorkflowState workflowState;

/**
 The last message that was received
 */
@property (nonatomic, copy) NSString *lastMessage;

/**
 The time of the last message
 */
@property (nonatomic, copy) NSDate *lastMessageAt;

/**
 The last message that the user authored
*/
@property (nonatomic, copy) NSString *lastAuthoredMessage;

/** 
 The time the last message the user authored
*/
@property (nonatomic, copy) NSDate *lastAuthoredMessageAt;

/**
 The total number of messages
 */
@property (nonatomic) NSUInteger messageCount;

/**
 Is the current user subscribed?
 */
@property (nonatomic) BOOL isSubscribed;

/**
 Is the message private?
 */
@property (nonatomic) BOOL isPrivate;

/**?
 Is the current user the last author
 */
@property (nonatomic) BOOL isLastAuthor;

/**
 Does the conversation have attachments?
 */
@property (nonatomic) BOOL hasAttachments;

/**
 Does the conversation contain media objects?
 */
@property (nonatomic) BOOL containsMediaObjects;

/**
 Audience user ids excluding current user (unless it's a monologue).
 */
@property (nonatomic, copy) NSArray *audienceIDs;

/**
 Audience contexts
 
 Most relevant shared contexts (courses and groups) between current user and other participants. If there is only one participant, it will also include that user's enrollment(s)/ membership type(s) in each course/group
 */
@property (nonatomic, copy) NSArray *audienceContexts;

/**
 The url for the relevant avatar
 */
@property (nonatomic, copy) NSURL *avatarURL;

/**
 Participants in the conversation
 */
@property (nonatomic, copy) NSArray *participants;

@property (nonatomic) NSArray *properties;

#pragma mark - Messages and Submissions
/**
 @name Messages and Submissions
 */


/**
 The `CKIConversationMessage`s for the conversation
 */
@property (nonatomic, copy) NSArray *messages;


@end



@interface CKIConversation (MergeNewMessage)
- (void)mergeNewMessageFromConversation:(CKIConversation *)conversation;
@end
