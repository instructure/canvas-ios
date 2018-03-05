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
