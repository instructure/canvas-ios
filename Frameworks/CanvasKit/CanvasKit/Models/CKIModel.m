//
//  CKIModel.m
//  CanvasKit
//
//  Created by Jason Larsen on 8/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIModel.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@implementation CKIModel {
    id<CKIContext> _context;
}

+ (NSString *)keyForJSONAPIContent
{
    return @"";
}

+ (instancetype)modelWithID:(NSString *)modelID
{
    return [self modelWithID:modelID context:CKIRootContext];
}

+ (instancetype)modelWithID:(NSString *)modelID context:(id<CKIContext>)context
{
    CKIModel *me = [self new];
    me.id = modelID;
    me.context = context;
    return me;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CKIModel class]]) {
        CKIModel *otherModel = (CKIModel *)object;
        return [self.id isEqualToString:otherModel.id];
    }
    return false;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{ 
    return @{@"context": [NSNull null]};
}

+ (NSValueTransformer *)idJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

// Overridden to prevent NSInvalidArgumentException in cases where the API
// is returning 'null' for integral types. Mantle does not check to see if
// the type of the property is an object type before calling setValue:forKey:
- (void)setNilValueForKey:(NSString *)key
{
    [self setValue:@(0) forKey:key];
}

+ (instancetype)modelFromJSONDictionary:(NSDictionary *)dictionaryValue
{
    NSError *error = nil;
    id model = [MTLJSONAdapter modelOfClass:self fromJSONDictionary:dictionaryValue error:&error];
    if (error){
        NSLog(@"Error parsing model %@", error);
    }
    
    return model;
}

- (NSDictionary *)JSONDictionary
{
    NSMutableDictionary *dictionary = [[MTLJSONAdapter JSONDictionaryFromModel:self] mutableCopy];
    
    // get rid of crap we don't want in the JSON - our context, and any NSNull values
    [dictionary removeObjectForKey:@"context"];
    NSMutableArray *keysToDelete = [NSMutableArray new];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            [keysToDelete addObject:key];
        }
    }];
    
    [keysToDelete enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
        [dictionary removeObjectForKey:key];
    }];
    
    return dictionary;
}

#pragma mark - CKIContext implementation

- (void)setContext:(id<CKIContext>)context
{
    _context = context;
}

- (id<CKIContext>)context
{
    if (_context == nil) {
        return CKIRootContext;
    }
    
    return _context;
}

- (NSString *)path
{
    // subclasses must provide a path implementation.
    return nil;
}

@end


