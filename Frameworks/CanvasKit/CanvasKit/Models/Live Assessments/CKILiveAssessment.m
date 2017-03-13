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

#import "CKILiveAssessment.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

@implementation CKILiveAssessment

+ (NSString *)keyForJSONAPIContent
{
    return @"assessments";
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *pathsByProperty = @{
        @"context": [NSNull null],
        @"outcomeID": @"links.outcome",
    };
    
    return [[super JSONKeyPathsByPropertyKey] dictionaryByAddingObjectsFromDictionary:pathsByProperty];
}

+ (NSValueTransformer *)idJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithBlock:^id(id value) {
        return value;
    }];
}

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"live_assessments"] stringByAppendingPathComponent:self.id];
}
@end
