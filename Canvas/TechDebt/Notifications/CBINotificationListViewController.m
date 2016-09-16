//
//  CBINotificationListViewController.m
//  iCanvas
//
//  Created by Derrick Hathaway on 7/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBINotificationListViewController.h"
#import "UIViewController+AnalyticsTracking.h"
#import "CBINotificationTableViewModel.h"
#import "UIImage+TechDebt.h"

@implementation CBINotificationListViewController
@dynamic viewModel;

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    self.navigationController.tabBarItem.selectedImage = [UIImage techDebtImageNamed:@"icon_notifications_tab_selected"];
}

- (CBINotificationTableViewModel *)viewModel {
    if (super.viewModel) {
        return super.viewModel;
    }
    
    return super.viewModel = [CBINotificationTableViewModel new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self sendTrackingByClassName];
}

@end
