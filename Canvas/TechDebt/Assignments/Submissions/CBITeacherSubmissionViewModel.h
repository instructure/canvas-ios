//
//  CBITeacherSubmissionViewModel.h
//  iCanvas
//
//  Created by Derrick Hathaway on 9/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"
#import "CBIAssignmentViewModel.h"

@interface CBITeacherSubmissionViewModel : CBIColorfulViewModel <CBISubmissionsViewModel>
@property (nonatomic) CKIAssignment *model;
@end
