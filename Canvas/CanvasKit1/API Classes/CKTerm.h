//
//  CKTerm.h
//  CanvasKit
//
//  Created by BJ Homer on 5/6/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKModelObject.h"

@interface CKTerm : CKModelObject

- (id)initWithInfo:(NSDictionary *)info;

@property (readonly) uint64_t ident;
@property (readonly) NSString *name;
@property (readonly) NSDate *startDate;
@property (readonly) NSDate *endDate;

@end
