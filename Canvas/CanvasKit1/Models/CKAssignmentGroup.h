//
//  CKAssignmentGroup.h
//  CanvasKit
//
//  Created by Zach Wily on 7/8/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@class CKCourse, CKAssignment;

@interface CKAssignmentGroup : CKModelObject

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int position;
@property (nonatomic, strong) NSMutableArray *assignments;
@property (nonatomic, weak) CKCourse *course;

- (id)initWithInfo:(NSDictionary *)info andCourse:(CKCourse *)course;

- (void)updateWithInfo:(NSDictionary *)info;

- (BOOL)addToGroup:(CKAssignment *)assignment;

- (NSComparisonResult)comparePosition:(CKAssignmentGroup *)other;

@end
