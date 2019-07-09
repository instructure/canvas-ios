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

#import "CKIDiscussionTopic.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "metamacros.h"
#import "CKILockInfo.h"
@import ReactiveObjC;
#import "CKIAttachment.h"

#define CKIJSONTransformer(property, tx) + (NSValueTransformer *) property ## JSONTransformer \
{ \
return (tx); \
}

#define CKIJSONTransformerForName(TX, ...) \
    metamacro_foreach_cxt(CKIJSONTransformerIterator,, ([NSValueTransformer valueTransformerForName:TX]), __VA_ARGS__)

#define CKIJSONTransformerIterator(INDEX, CONTEXT, VAR) \
    CKIJSONTransformer(VAR, CONTEXT)


@implementation CKIDiscussionTopic

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *mine = @{
        @"messageHTML": @"message",
        @"htmlURL": @"html_url",
        @"postedAt": @"posted_at",
        @"lastReplyAt": @"last_reply_at",
        @"requireInitialPost": @"require_initial_post",
        @"userCanSeePosts": @"user_can_see_posts",
        @"subentryCount": @"discussion_subentry_count",
        @"isRead": @"read_state",
        @"unreadCount": @"unread_count",
        @"isSubscribed": @"subscribed",
        @"subscriptionHold": @"subscription_hold",
        @"assignmentID": @"assignment_id",
        @"delayedPostAt": @"delayed_post_at",
        @"isPublished": @"published",
        @"lockAt": @"lock_at",
        @"isLocked": @"locked",
        @"isPinned": @"pinned",
        @"isLockedForUser": @"locked_for_user",
        @"lockInfo": @"lock_info",
        @"lockExplanation": @"lock_explanation",
        @"userName": @"user_name",
        @"childrenTopicIDs": @"topic_children",
        @"rootTopicID": @"root_topic_id",
        @"podcastURL": @"podcast_url",
        @"type": @"discussion_type",
        @"canAttachPermission": @"permissions.attach",
        @"position" : @"position"
    };
    
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:mine];
}

CKIJSONTransformerForName(CKIDateTransformerName, postedAt, lastReplyAt, lockAt, delayedPostAt);
CKIJSONTransformerForName(MTLURLValueTransformerName, htmlURL, podcastURL);
CKIJSONTransformerForName(CKINumberStringTransformerName, assignmentID, rootTopicID);

+ (NSValueTransformer *)isReadJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *readStatus) {
        return @([readStatus isEqualToString:@"read"]);
    } reverseBlock:^id(NSNumber *isRead) {
        return [isRead boolValue] ? @"read" : @"unread";
    }];
}

+ (NSValueTransformer *)subscriptionHoldJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *hold) {
        if ([hold isEqualToString:@"not_in_group_set"]) {
            return @(CKIDiscussionTopicSubscriptionHoldNotInGroupSet);
        } else if ([hold isEqualToString:@"not_in_group"]) {
            return @(CKIDiscussionTopicSubscriptionHoldNotInGroup);
        } else if ([hold isEqualToString:@"topic_is_announcement"]) {
            return @(CKIDiscussionTopicSubscriptionHoldTopicIsAnnouncement);
        } else if ([hold isEqualToString:@"initial_post_required"]) {
            return @(CKIDiscussionTopicSubscriptionHoldInitialPostRequired);
        } else {
            return @(CKIDiscussionTopicSubscriptionHoldNone);
        }
    } reverseBlock:^id(id hold) {
        switch ([hold integerValue]) {
            case CKIDiscussionTopicSubscriptionHoldNotInGroup:
                return @"not_in_group";
            case CKIDiscussionTopicSubscriptionHoldNotInGroupSet:
                return @"not_in_group_set";
            case CKIDiscussionTopicSubscriptionHoldTopicIsAnnouncement:
                return @"topic_is_announcement";
            case CKIDiscussionTopicSubscriptionHoldInitialPostRequired:
                return @"initial_post_required";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)lockInfoJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CKILockInfo class]];
}

+ (NSValueTransformer *)childrenTopicIDsJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray *integerIDs) {
        return [[integerIDs.rac_sequence map:^id(id value) {
            return [value description];
        }] array];
    } reverseBlock:^id(NSArray *stringIDs) {
        return [[stringIDs.rac_sequence map:^id(id value) {
            return @([value integerValue]);
        }] array];
    }];
}

+ (NSValueTransformer *)typeJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *typeString) {
        return @([typeString isEqualToString:@"threaded"] ? CKIDiscussionTopicTypeThreaded : CKIDiscussionTopicTypeSideComment);
    } reverseBlock:^id(NSNumber *discustionTopicType) {
        return ([discustionTopicType integerValue] == CKIDiscussionTopicTypeThreaded) ? @"threaded" : @"side_comment";
    }];
}

+ (NSValueTransformer *)attachmentsJSONTransformer
{
    return [MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKIAttachment class]];
}


- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"discussion_topics"] stringByAppendingPathComponent:self.id];
}
@end
