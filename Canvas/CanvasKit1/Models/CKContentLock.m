//
//  CKContentLock.m
//  CanvasKit
//
//  Created by Jason Larsen on 5/8/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKContentLock.h"
#import "NSDictionary+CKAdditions.h"
#import "ISO8601DateFormatter.h"

@interface CKContentLock ()
@property ISO8601DateFormatter *apiDateFormatter;
@end

@implementation CKContentLock

+ (id)contentLockWithInfo:(NSDictionary *)info {
    return [[CKContentLock alloc] initWithInfo:info];
}

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        _apiDateFormatter = [ISO8601DateFormatter new];
        
        NSDictionary *dict = [info safeCopy];
        
        BOOL lockedForUser = [dict[@"locked_for_user"] boolValue];
        if (!lockedForUser) {
            return nil; // this item is not locked, don't return a lock object
        }
        
        _explanation = dict[@"lock_explanation"];
        
        NSDictionary *lockInfo = [dict[@"lock_info"] safeCopy];
        NSDictionary *contextModule = [lockInfo[@"context_module"] safeCopy];
        _prerequisites =  contextModule[@"prerequisites"];
        NSString *startDateString = contextModule[@"start_at"];
        NSString *unlockDateString = contextModule[@"unlock_at"] ? contextModule[@"unlock_at"] : lockInfo[@"unlock_at"];
        NSString *lockDateString = dict[@"lock_at"];
        if (startDateString) {
            _startDate = [_apiDateFormatter dateFromString:startDateString];
        }
        
        if (unlockDateString) {
            _unlockDate = [_apiDateFormatter dateFromString:unlockDateString];
        }
        
        if (lockDateString) {
            _lockDate = [_apiDateFormatter dateFromString:lockDateString];
        }
        
        _moduleName = dict[@"lock_info"][@"context_module"][@"name"];
    }
    return self;
}

- (NSArray *)prerequisiteNames {
    NSMutableArray *array = [NSMutableArray new];
    [self.prerequisites enumerateObjectsUsingBlock:^(NSDictionary *prereq, NSUInteger idx, BOOL *stop) {
        [array addObject:prereq[@"name"]];
    }];
    return [array copy];
}

@end
