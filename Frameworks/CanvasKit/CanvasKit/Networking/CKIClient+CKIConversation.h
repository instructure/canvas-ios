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

#import "CKIClient.h"
#import "CKIConversation.h"

typedef NS_ENUM(NSInteger, CKIConversationScope) {
    CKIConversationScopeInbox,
    CKIConversationScopeUnread,
    CKIConversationScopeArchived,
    CKIConversationScopeSent,
    CKIConversationScopeStarred,
};

@interface CKIClient (CKIConversation)
- (RACSignal *)fetchConversationsInScope:(CKIConversationScope)scope;

- (RACSignal *)refreshConversation:(CKIConversation *)conversation;

/**
 on success the signal will send a single CKIConversation object (pretty sure)
 */
- (RACSignal *)createConversationWithRecipientIDs:(NSArray *)recipients message:(NSString *)message;
- (RACSignal *)createConversationWithRecipientIDs:(NSArray *)recipients message:(NSString *)message attachmentIDs:(NSArray *)attachmentIDs;

/**
 posts message to the given conversation with the attachment IDs provided
 */
- (RACSignal *)createMessage:(NSString *)message inConversation:(CKIConversation *)conversation withAttachmentIDs:(NSArray *)attachments;

/**
 updates the conversation to include the recipients
 
 @param recipientIDs array of string ids for users
 */
- (RACSignal *)addNewRecipientsIDs:(NSArray *)recipientIDs toConversation:(CKIConversation *)conversation;


/**
 marks the conversation as read/unread/archived
 */
- (RACSignal *)markConversation:(CKIConversation *)conversation asWorkflowState:(CKIConversationWorkflowState)state;
@end
