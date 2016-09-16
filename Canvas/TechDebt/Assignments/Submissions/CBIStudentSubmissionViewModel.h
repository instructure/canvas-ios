//
//  CBIAssignmentSubmissionsViewModel.h
//  iCanvas
//
//  Created by Derrick Hathaway on 9/15/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"
#import "CBIAssignmentViewModel.h"

@interface CBIStudentSubmissionViewModel : CBIColorfulViewModel <CBISubmissionsViewModel>
@property (nonatomic) CKIAssignment *model;
@property (nonatomic) CKISubmissionRecord *record;
@property (nonatomic) CKIUser *student;
@property (nonatomic) BOOL forTeacher;
@end
