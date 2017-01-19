//
//  CKIGroupCategory.m
//  CanvasKit
//
//  Created by Brandon Pluim on 12/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIGroupCategory.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

@implementation CKIGroupCategory

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"selfSignup": @"self_signup",
                               @"autoLeader": @"auto_leader",
                               @"contextType": @"context_type",
                               @"accountID": @"account_id",
                               @"groupLimit": @"group_limit",
                               };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

- (NSString *)path
{
    NSString *path = self.context.path;
    path = [path stringByAppendingPathComponent:@"group_categories"];
    return [path stringByAppendingPathComponent:self.id];
}

@end
