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
