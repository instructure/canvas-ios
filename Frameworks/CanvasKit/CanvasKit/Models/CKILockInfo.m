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

#import "CKILockInfo.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@implementation CKILockInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"assetString": @"asset_string",
        @"unlockAt": @"context_module.unlock_at",
        @"startAt": @"context_module.start_at",
        @"endAt": @"context_module.end_at",
        @"moduleID": @"context_module.id",
        @"moduleName": @"context_module.name",
        @"moduleCourseID": @"context_module.context_id",
        @"canView": @"can_view"
    };
}

+ (NSValueTransformer *)unlockAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)startAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)endAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)moduleIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)moduleCourseIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

@end
