//
//  CKIPage.m
//  CanvasKit
//
//  Created by Jason Larsen on 9/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIPage.h"
#import "CKIUser.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@interface CKIPage()
// these are private properties used to store the JSON values
// and used to create the derived lastEditedBy property.
@property (nonatomic, copy) NSString *lastEditedByID;
@property (nonatomic, copy) NSString *lastEditedByDisplayName;
@property (nonatomic, strong) NSURL *lastEditedByAvatarURL;
@end

@implementation CKIPage

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
        @"id": @"url",
        @"createdAt": @"created_at",
        @"updatedAt": @"updated_at",
        @"hideFromStudents": @"hide_from_students",
        @"lastEditedByID": @"last_edited_by.id",
        @"lastEditedByDisplayName": @"last_edited_by.display_name",
        @"lastEditedByAvatarURL": @"last_edited_by.avatar_image_url",
        @"published": @"published",
        @"frontPage": @"front_page",
        @"lockedForUser": @"locked_for_user",
        @"lockInfo": @"lock_info",
        @"lockExplanation": @"lock_explanation",
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)idJSONTransformer
{
    return nil;
}

+ (NSValueTransformer *)createdAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)updatedAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)lastEditedByIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)lastEditedByAvatarURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

- (CKIUser *)lastEditedBy
{
    CKIUser *user = [CKIUser new];
    user.id = self.lastEditedByID;
    user.name = self.lastEditedByDisplayName;
    user.avatarURL = self.lastEditedByAvatarURL;
    
    return user;
}

- (NSString *)path
{
    NSString *path = self.context.path;
    path = [path stringByAppendingPathComponent:@"pages"];
    return [path stringByAppendingPathComponent:self.id];
}

@end
