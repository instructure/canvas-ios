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
 
 @param array of string ids for users
 */
- (RACSignal *)addNewRecipientsIDs:(NSArray *)recipientIDs toConversation:(CKIConversation *)conversation;


/**
 marks the conversation as read/unread/archived
 */
- (RACSignal *)markConversation:(CKIConversation *)conversation asWorkflowState:(CKIConversationWorkflowState)state;
@end
