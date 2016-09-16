//
//  CBIAssignmentViewModel.h
//  iCanvas
//
//  Created by derrick on 11/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBILockableViewModel.h"
@import MyLittleViewController;

@protocol CBISubmissionsViewModel <MLVCTableViewModel>
- (UIViewController *)createViewController;
@end

@class CKIAssignment;
@interface CBIAssignmentViewModel : CBILockableViewModel

@property (nonatomic, strong) CKIAssignment *model;
@property (nonatomic, assign) int index;

@property (nonatomic) NSDate *syllabusDate;
@property (nonatomic) NSDate *dueAt;

- (RACSignal *)fetchSubmissionsViewModel;

@end
