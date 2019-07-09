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
