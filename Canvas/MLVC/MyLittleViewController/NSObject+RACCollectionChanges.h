//
//  NSObject+RACCollectionChanges.h
//  MyLittleViewController
//
//  Created by derrick on 10/15/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;
@interface NSObject (RACCollectionChanges)
- (RACSignal *)rac_filteredIndexSetsForChangeType:(NSKeyValueChange)type forCollectionForKeyPath:(NSString *)collectionKeyPath;
@end
