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

#import "CKIModule.h"
#import "CKIModuleItem.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

NSString * const CKIModuleStateLocked = @"locked";
NSString * const CKIModuleStateUnlocked = @"unlocked";
NSString * const CKIModuleStateStarted = @"started";
NSString * const CKIModuleStateCompleted = @"completed";

NSString * const CKIModuleWorkflowStateActive = @"active";
NSString * const CKIModuleWorkflowStateDeleted = @"deleted";

@implementation CKIModule

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
        @"workflowState": @"workflow_state",
        @"unlockAt": @"unlock_at",
        @"requireSequentialProgress": @"require_sequential_progress",
        @"itemsCount": @"items_count",
        @"itemsAPIURL": @"items_url",
        @"completedAt": @"completed_at",
        @"prerequisiteModuleIDs": @"prerequisite_module_ids"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)unlockAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)itemsAPIURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)prerequisiteModuleIDsAPIURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)completedAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)itemsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKIModuleItem class]];
}


- (NSString *)path
{
    return [[[self.context path] stringByAppendingPathComponent:@"modules"] stringByAppendingPathComponent:self.id];
}

@end
