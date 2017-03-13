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

#import "CKIAttachment.h"
#import "CKIDiscussionEntry.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "metamacros.h"

#define CKIJSONTransformer(property, tx) + (NSValueTransformer *) property ## JSONTransformer \
{ \
return (tx); \
}

#define CKIJSONTransformerForName(TX, ...) \
metamacro_foreach_cxt(CKIJSONTransformerIterator,, ([NSValueTransformer valueTransformerForName:TX]), __VA_ARGS__)

#define CKIJSONTransformerIterator(INDEX, CONTEXT, VAR) \
CKIJSONTransformer(VAR, CONTEXT)



@implementation CKIDiscussionEntry

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *mine = @{
        @"userID": @"user_id",
        @"editorID": @"editor_id",
        @"userName": @"user_name",
        @"read": @"read_state",
        @"manuallyMarkedReadOrUnread": @"forced_read_state",
        @"createdAt": @"created_at",
        @"updatedAt": @"updated_at",
        @"recentReplies": @"recent_replies",
        @"hasMoreReplies": @"has_more_replies",
    };
    
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:mine];
}

CKIJSONTransformerForName(CKIDateTransformerName, createdAt, updatedAt);
CKIJSONTransformerForName(CKINumberStringTransformerName, userID, editorID);

+ (NSValueTransformer *)readJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *readState) {
        return @([readState isEqualToString:@"read"]);
    } reverseBlock:^id(NSNumber *value) {
        return [value boolValue] ? @"read" : @"unread";
    }];
}

+ (NSValueTransformer *)recentRepliesJSONTransformer {
    return [MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKIDiscussionEntry class]];
}

+ (NSValueTransformer *)attachmentJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CKIAttachment class]];
}

@end
