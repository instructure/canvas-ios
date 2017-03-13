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
