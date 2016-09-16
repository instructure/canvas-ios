//
//  CKStudent.h
//  CanvasKit
//
//  Created by Zach Wily on 5/17/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@interface CKStudent : CKModelObject

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, strong) NSString *name;
@property (weak, nonatomic, readonly) NSString *keyString;

- (id)initWithInfo:(NSDictionary *)info;

- (void)updateWithInfo:(NSDictionary *)info;

+ (NSMutableArray *)shuffledArrayOfStudents:(NSArray *)studentsToSort;

@end
