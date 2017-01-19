//
//  CKITodoItem.m
//  CanvasKit
//
//  Created by rroberts on 9/17/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKITodoItem.h"
#import "CKIAssignment.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@implementation CKITodoItem

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"type": @"type",
                               @"ignore": @"ignore",
                               @"ignorePermanently": @"ignore_permanently",
                               @"htmlUrl": @"html_url",
                               @"needsGradingCount": @"needs_grading_count",
                               @"contextType": @"context_type",
                               @"courseID": @"course_id",
                               @"groupID": @"group_id"
                               };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)courseIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)groupIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)ignoreJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)ignorePermanentlyJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)htmlUrlJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)assignmentJSONTransformer
{
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CKIAssignment class]];
}

- (NSString *)path
{
    // The canvas api doesn't provide ids for individual todo items and
    // it is not possible to address a todo item directly. This path is
    // provided for consistency and because we want to use it :)
    return [[CKIRootContext.path stringByAppendingPathComponent:@"users/self/todo"] stringByAppendingPathComponent:self.assignment.id];
}

@end
