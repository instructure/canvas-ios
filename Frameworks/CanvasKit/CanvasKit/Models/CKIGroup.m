//
//  CKIGroup.m
//  CanvasKit
//
//  Created by Jason Larsen on 10/1/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
