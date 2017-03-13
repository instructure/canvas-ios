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