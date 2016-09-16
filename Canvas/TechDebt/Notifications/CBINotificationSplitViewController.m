//
//  CBINotificationSplitViewController.m
//  iCanvas
//
//  Created by Jason Larsen on 12/2/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import MyLittleViewController;

#import "CBINotificationSplitViewController.h"
#import "CBINotificationListViewController.h"
#import "UIViewController+AnalyticsTracking.h"
#import "UIImage+TechDebt.h"


@implementation CBINotificationSplitViewController

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    self.navigationController.tabBarItem.selectedImage = [UIImage techDebtImageNamed:@"icon_notifications_tab_selected"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CBINotificationListViewController *todoTableViewController = [CBINotificationListViewController new];
    todoTableViewController.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    
    self.master = todoTableViewController;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self sendTrackingByClassName];
}

@end
