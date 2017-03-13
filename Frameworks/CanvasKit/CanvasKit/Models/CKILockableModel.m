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

#import "CKILockableModel.h"
#import "CKILockInfo.h"

@implementation CKILockableModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPaths = [@{
        @"lockedForUser": @"locked_for_user",
        @"lockExplanation": @"lock_explanation",
        @"lockInfo": @"lock_info"
    } mutableCopy];
    [keyPaths addEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
    return keyPaths;
}

+ (NSValueTransformer *)lockInfoJSONTransformer
{
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CKILockInfo class]];
}

@end
