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
