//
//  CBISubmissionCommentViewModel.h
//  iCanvas
//
//  Created by Derrick Hathaway on 9/15/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"
#import "CBISubmissionDialogViewModel.h"

@interface CBISubmissionCommentViewModel : CBIColorfulViewModel <CBISubmissionDialogViewModel>
@property (nonatomic) CKISubmissionComment *model;
@property (nonatomic) NSDate *date;

+ (void)registerCellsForTableView:(UITableView *)tableView;
@end
