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

#import "CKIGroup.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

NSString * const CKIGroupJoinLevelParentContextAutoJoin = @"parent_context_auto_join";
NSString * const CKIGroupJoinLevelParentContextRequest = @"parent_context_request";
NSString * const CKIGroupJoinLevelInvitationOnly = @"invitation_only";

@implementation CKIGroup

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
        @"groupDescription": @"description",
        @"isPublic": @"is_public",
        @"followedByUser": @"followed_by_user",
        @"membersCount": @"members_count",
        @"avatarURL": @"avatar_url",
        @"joinLevel": @"join_level",
        @"courseID": @"course_id"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)avatarURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)courseIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"groups"] stringByAppendingPathComponent:self.id];
}

@end
