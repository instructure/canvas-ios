//
//  NSDictionary+CKAdditions.h
//  Speed Grader
//
//  Created by Zach Wily on 7/9/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (CKAdditions)

// returns a CKSafeDictionary that always does objectForKeyCheckingNull
+ (id)safeDictionaryWithDictionary:(NSDictionary *)dictionary;
- (id)safeCopy;

// returns nil if the object that corresponds to key is [NSNull null]
- (id)objectForKeyCheckingNull:(id)aKey;

@end
