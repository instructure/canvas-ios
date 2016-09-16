//
//  CBISubmissionCell.h
//  iCanvas
//
//  Created by Derrick Hathaway on 9/16/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulCell.h"

@class CBISubmissionViewModel;

@interface CBISubmissionCell : UITableViewCell
@property (nonatomic) CBISubmissionViewModel *viewModel;
@end
