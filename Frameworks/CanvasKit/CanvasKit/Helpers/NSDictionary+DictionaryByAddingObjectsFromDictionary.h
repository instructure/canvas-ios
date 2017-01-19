//
//  NSDictionary+DictionaryByAddingObjectsFromDictionary.h
//  CanvasKit
//
//  Created by Jason Larsen on 9/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DictionaryByAddingObjectsFromDictionary)
- (NSDictionary *)dictionaryByAddingObjectsFromDictionary:(NSDictionary *)dictionary;
@end
