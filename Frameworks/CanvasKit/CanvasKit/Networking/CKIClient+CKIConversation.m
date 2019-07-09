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

#import "CKIClient+CKIConversation.h"
#import "CKIClient+CKIModel.h"
@import ReactiveObjC;

NSString *CKIStringForConversationScope(CKIConversationScope scope) {
    switch (scope) {
        case CKIConversationScopeArchived:
            return @"archived";
        case CKIConversationScopeUnread:
            return @"unread";
        case CKIConversationScopeSent:
            return @"sent";
        case CKIConversationScopeStarred:
            return @"starred";
        default:
            return nil;
    }
}

@implementation CKIClient (CKIConversation)
- (RACSignal *)fetchConversationsInScope:(CKIConversationScope)scope
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"conversations"];
    
    NSMutableDictionary *params = [@{@"interleave_submissions": @(1)} mutableCopy];
    NSString *scopeString = CKIStringForConversationScope(scope);
    if (scope) {
        params[@"scope"] = scopeString;
    }
    
    return [self fetchResponseAtPath:path parameters:params modelClass:[CKIConversation class] context:CKIRootContext];
}

- (RACSignal *)refreshConversation:(CKIConversation *)conversation
{
    return [self refreshModel:conversation parameters:@{@"interleave_submissions": @(1)}];
}


- (RACSignal *)createConversationWithRecipientIDs:(NSArray *)recipients message:(NSString *)message
{
    return [self createConversationWithRecipientIDs:recipients message:message attachmentIDs:nil];
}
- (RACSignal *)createConversationWithRecipientIDs:(NSArray *)recipients message:(NSString *)message attachmentIDs:(NSArray *)attachmentIDs
{
    NSString *path = [[CKIRootContext path] stringByAppendingPathComponent:@"conversations"];
    NSMutableDictionary *parameters = [@{@"recipients": recipients, @"body": message} mutableCopy];
    if ([attachmentIDs count]) {
        parameters[@"attachment_ids"] = [attachmentIDs copy];
    }
    
    return [self createModelAtPath:path parameters:parameters modelClass:[CKIConversation class] context:CKIRootContext];
}

- (RACSignal *)createMessage:(NSString *)message inConversation:(CKIConversation *)conversation withAttachmentIDs:(NSArray *)attachments
{
    NSString *path = [[conversation path] stringByAppendingPathComponent:@"add_message"];
    NSMutableDictionary *parameters = [@{@"body": message} mutableCopy];
    if ([attachments count]) {
        parameters[@"attachment_ids"] = attachments;
    }
    
    return [self createModelAtPath:path parameters:parameters modelClass:[CKIConversation class] context:conversation.context];
}

- (RACSignal *)addNewRecipientsIDs:(NSArray *)recipientIDs toConversation:(CKIConversation *)conversation
{
    NSString *path = [[conversation path] stringByAppendingPathComponent:@"add_recipients"];
    NSDictionary *parameters = @{@"recipients": recipientIDs};
    
    return [[self createModelAtPath:path parameters:parameters modelClass:[CKIConversation class] context:conversation.context] map:^(CKIConversation *updatedConversation) {
        [[CKIConversation propertyKeys] enumerateObjectsUsingBlock:^(NSString *property, BOOL *stop) {
            if ([@[@"messages", @"context"] containsObject:property]) {
                return;
            }
            [conversation mergeValueForKey:property fromModel:updatedConversation];
        }];
        conversation.messages = [updatedConversation.messages arrayByAddingObjectsFromArray:conversation.messages];

        return conversation;
    }];
    
}


- (RACSignal *)markConversation:(CKIConversation *)conversation asWorkflowState:(CKIConversationWorkflowState)state
{
    return [self updateModel:conversation parameters:@{@"conversation": @{@"workflow_state" : CKIStringForConversationScope((CKIConversationScope)state)}}];
}

@end
