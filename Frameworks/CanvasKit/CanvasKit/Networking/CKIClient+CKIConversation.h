//
//  CKIClient+CKIConversation.h
//  CanvasKit
//
//  Created by derrick on 11/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
