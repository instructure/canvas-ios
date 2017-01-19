//
//  CKITodoItem.h
//  CanvasKit
//
//  Created by rroberts on 9/17/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIModel.h"
@class CKIAssignment;

@interface CKITodoItem : CKIModel

@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) CKIAssignment *assignment;

@property (nonatomic, strong) NSURL *ignore;

@property (nonatomic, strong) NSURL *ignorePermanently;

@property (nonatomic, strong) NSURL *htmlUrl;

@property (nonatomic) NSInteger needsGradingCount;

@property (nonatomic, strong) NSString *courseID;

@property (nonatomic, strong) NSString *contextType;

@property (nonatomic, strong) NSString *groupID;

@end
