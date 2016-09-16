//
//  CBIAssignmentDetailViewController.h
//  iCanvas
//
//  Created by nlambson on 12/12/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import MyLittleViewController;
#import "CBIAssignmentViewModel.h"

@interface CBIAssignmentDetailViewController : MLVCViewController
@property (nonatomic, strong) CBIAssignmentViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UIView *toolbarControl;
@end
