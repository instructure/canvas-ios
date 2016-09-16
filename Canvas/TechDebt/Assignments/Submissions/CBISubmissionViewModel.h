//
//  CBISubmissionViewModel.h
//  iCanvas
//
//  Created by Derrick Hathaway on 9/15/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"
#import "CBISubmissionDialogViewModel.h"

@interface CBISubmissionViewModel : CBIColorfulViewModel <CBISubmissionDialogViewModel>
@property (nonatomic) CKISubmission *model;
@property (nonatomic) CKIAssignment *assignment;
@property (nonatomic) NSDate *date;

+ (void)registerCellsForTableView:(UITableView *)tableView;
@end
