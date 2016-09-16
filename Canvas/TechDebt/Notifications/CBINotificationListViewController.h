//
//  CBINotificationListViewController.h
//  iCanvas
//
//  Created by Derrick Hathaway on 7/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

@import MyLittleViewController;

@class CBINotificationTableViewModel;

@interface CBINotificationListViewController : MLVCTableViewController
@property (nonatomic) CBINotificationTableViewModel *viewModel;
@end
