//
//  CKIModel.h
//  CanvasKit
//
//  Created by Jason Larsen on 8/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import Mantle;
#import "CKIContext.h"

@interface CKIModel : MTLModel <MTLJSONSerializing, CKIContext>

+ (NSString *)keyForJSONAPIContent;

/**
 Creates an empty model with the given ID assumes the `CKIRootContext`
 */
+ (instancetype)modelWithID:(NSString *)modelID;

/**
 Creates an empty model with the given ID in the given context
 */
+ (instancetype)modelWithID:(NSString *)modelID context:(id<CKIContext>)context;

/**
 The unique identifier assigned to this model.
 */
@property (nonatomic, copy) NSString *id;

/**
 the base url for this model object
 */
@property (nonatomic) NSURL *baseURL;

/**
 Checks to see if two models are equivalent based on their ID.
 
 @param object the object to compare
 
 @returns true if objects have same IDs, else false.
 */
- (BOOL)isEqual:(id)object;
    

/**
 Convenience method for instantiating class from a JSON dictionary.
 */
+ (instancetype)modelFromJSONDictionary:(NSDictionary *)dictionaryValue;

/**
 Convenience method for turning model into JSON dictionary.
 */
- (NSDictionary *)JSONDictionary;

@end
