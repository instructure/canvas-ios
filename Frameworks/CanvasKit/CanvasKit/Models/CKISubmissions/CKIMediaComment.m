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

//
// CKIMediaComment.m
// Created by Jason Larsen on 5/8/14.
//

#import "CKIMediaComment.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

NSString * const CKIMediaCommentMediaTypeAudio = @"audio";
NSString * const CKIMediaCommentMediaTypeVideo = @"video";

@interface CKIMediaComment ()

@end

@implementation CKIMediaComment

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
            @"id": @"media_id",
            @"mediaID" : @"media_id",
            @"displayName" : @"display_name",
            @"contentType" : @"content-type", // watch the - !
            @"mediaType" : @"media_type",
            @"url" : @"url"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)urlJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

// override the CKIModel version because mediaID is already a string
+ (NSValueTransformer *)idJSONTransformer {
    return nil;
}

@end