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

#import "CKIOutcomeLink.h"

#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

#import "CKIOutcome.h"
#import "CKIOutcomeGroup.h"

@implementation CKIOutcomeLink

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"contextID": @"context_id",
                               @"contextType": @"context_type",
                               @"outcomeGroup": @"outcome_group",
                               };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)contextIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)outcomeGroupJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CKIOutcomeGroup class]];
}

+ (NSValueTransformer *)outcomeJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CKIOutcome class]];
}

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"outcomes"] stringByAppendingPathComponent:self.id];
}

@end
