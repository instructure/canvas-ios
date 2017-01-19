//
//  CKIModule.m
//  CanvasKit
//
//  Created by Jason Larsen on 9/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
