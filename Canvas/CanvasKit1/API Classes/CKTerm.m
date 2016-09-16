//
//  CKTerm.m
//  CanvasKit
//
//  Created by BJ Homer on 5/6/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKTerm.h"
#import "ISO8601DateFormatter.h"
#import "CKSafeDictionary.h"

@implementation CKTerm

// {
// "end_at": "2012-06-15T00:00:00-06:00",
// "id": 4699,
// "name": "Spring 2012",
// "start_at": "2012-03-16T00:00:00-06:00"
//}

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        CKSafeDictionary *safeInfo = [CKSafeDictionary dictionaryWithDictionary:info];
        _ident = [safeInfo[@"id"] unsignedLongLongValue];
        _name = safeInfo[@"name"];
        
        if (safeInfo[@"start_at"]) {
            _startDate = [self.apiDateFormatter dateFromString:safeInfo[@"start_at"]];
        }
        if (safeInfo[@"end_at"]) {
            _endDate = [self.apiDateFormatter dateFromString:safeInfo[@"end_at"]];
        }
    }
    return self;
}

- (NSUInteger)hash {
    return self.ident;
}

@end
