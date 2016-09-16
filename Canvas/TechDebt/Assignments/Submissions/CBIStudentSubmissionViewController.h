//
//  CBIAssignmentSubmissionsViewController.h
//  iCanvas
//
//  Created by Derrick Hathaway on 9/16/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

@import MyLittleViewController;
#import "CBIStudentSubmissionViewModel.h"

@interface CBIStudentSubmissionViewController : MLVCTableViewController
@property (nonatomic) CBIStudentSubmissionViewModel *viewModel;

- (void)submitComment:(NSString *)commentText onSuccess:(void (^)())success onFailure:(void (^)())failure;
- (void)chooseMediaComment:(UIButton *)sender;
@end
