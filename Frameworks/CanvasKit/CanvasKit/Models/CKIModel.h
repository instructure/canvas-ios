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
