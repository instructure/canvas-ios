//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

@import MyLittleViewController;

#import "CBINotificationSplitViewController.h"
#import "CBINotificationListViewController.h"
#import "UIViewController+AnalyticsTracking.h"
#import "UIImage+TechDebt.h"


@implementation CBINotificationSplitViewController

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
