//
//  CKRubric.h
//  CanvasKit
//
//  Created by Zach Wily on 7/9/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@class CKAssignment;

@interface CKRubric : CKModelObject

@property (nonatomic, weak) CKAssignment *assignment;
@property (strong, nonatomic, readonly) NSMutableArray *criteria;
@property (nonatomic, assign) BOOL freeFormComments;

// You actually pass it the Assignment dictionary, and it will extract what it needs
- (id)initWithInfo:(NSDictionary *)info andAssignment:(CKAssignment *)anAssignment;

- (void)updateWithInfo:(NSDictionary *)info;

@end
