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

#import "CKILiveAssessmentResult.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "CKILiveAssessment.h"

@implementation CKILiveAssessmentResult

@dynamic context;

+ (NSString *)keyForJSONAPIContent
{
    return @"results";
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
        @"assessedAt": @"assessed_at",
        @"assessedUserID": @"links.user",
        @"assessorUserID": @"links.assessor",
        @"context": [NSNull null],
    };
    
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"results"] stringByAppendingPathComponent:self.id];
}

+ (NSValueTransformer *)idJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithBlock:^id(id value) {
        return value;
    }];
}

+ (NSValueTransformer *)assessedAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

@end
