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
