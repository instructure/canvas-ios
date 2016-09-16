//
//  CKObject.h
//  CanvasKit
//
//  Created by BJ Homer on 12/13/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ISO8601DateFormatter;

@interface CKModelObject : NSObject

// Note: 'weak' properties are already automatically excluded
+ (NSArray *)propertiesToExcludeFromEqualityComparison;

- (ISO8601DateFormatter *)apiDateFormatter;

@end
