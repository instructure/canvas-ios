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

#import "CKIConversation.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
#import "CKIUser.h"
#import "CKIConversationMessage.h"
#import "CKISubmission.h"
@import ReactiveObjC;

@interface CKIConversation ()

@end

@implementation CKIConversation
+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
        @"workflowState": @"workflow_state",
        @"lastMessage": @"last_message",
        @"lastMessageAt": @"last_message_at",
        @"lastAuthoredMessage": @"last_authored_message",
        @"lastAuthoredMessageAt": @"last_authored_message_at",
        @"messageCount": @"message_count",
        @"isSubscribed": @"subscribed",
        @"isPrivate": @"private",
        @"audienceContexts": @"audience_contexts",
        @"avatarURL": @"avatar_url",
        @"audienceIDs": @"audience"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)workflowStateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *workflowState) {
        if ([workflowState isEqualToString:@"read"]) {
            return @(CKIConversationWorkflowStateRead);
        } else if ([workflowState isEqualToString:@"archived"]) {
            return @(CKIConversationWorkflowStateArchived);
        } else {
            return @(CKIConversationWorkflowStateUnread);
        }
    } reverseBlock:^id(NSNumber *state) {
        switch ([state integerValue]) {
            case CKIConversationWorkflowStateRead:
                return @"read";
            case CKIConversationWorkflowStateArchived:
                return @"archived";
            default:
            case CKIConversationWorkflowStateUnread:
                return @"unread";
        }
    }];
}

+ (NSValueTransformer *)lastMessageAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)lastAuthoredMessageAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)audienceIDsJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *arrayOfLongLongs) {
        return [[arrayOfLongLongs.rac_sequence map:^id(id value) {
            return [value description];
        }] array];
    } reverseBlock:^(NSArray *arrayOfStrings) {
        return [[arrayOfStrings.rac_sequence map:^id(id value) {
            return @([value longLongValue]);
        }] array];
    }];
}

+ (NSValueTransformer *)avatarURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)participantsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKIUser class]];
}

+ (NSValueTransformer *)messagesJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKIConversationMessage class]];
}

- (void)setProperties:(NSArray *)properties
{
    self.isLastAuthor = [properties containsObject:@"last_author"];
    self.hasAttachments = [properties containsObject:@"attachments"];
    self.containsMediaObjects = [properties containsObject:@"media_object"];
}

- (NSArray *)properties
{
    NSMutableArray *array = [NSMutableArray array];
    
    if (self.isLastAuthor) {
        [array addObject:@"last_author"];
    }
    if (self.hasAttachments) {
        [array addObject:@"attachments"];
    }
    if (self.containsMediaObjects) {
        [array addObject:@"media_objects"];
    }
    
    return array;
}


#pragma mark - path

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"conversations"] stringByAppendingPathComponent:self.id];
}

@end


@implementation CKIConversation (MergeNewMessage)

- (void)mergeNewMessageFromConversation:(CKIConversation *)conversation
{
    CKIConversationMessage *message = [conversation.messages firstObject];
    if (message) {
        self.lastMessage = message.body;
        NSMutableArray *current = [self.messages mutableCopy];
        [current insertObject:message atIndex:0];
        self.messages = current;
    }
}

@end
