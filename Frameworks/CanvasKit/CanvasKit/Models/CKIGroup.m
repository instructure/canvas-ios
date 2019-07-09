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
