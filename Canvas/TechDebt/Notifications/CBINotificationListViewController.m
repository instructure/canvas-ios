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
    
    

#import "CBINotificationListViewController.h"
#import "UIViewController+AnalyticsTracking.h"
#import "CBINotificationTableViewModel.h"
#import "UIImage+TechDebt.h"

@implementation CBINotificationListViewController
@dynamic viewModel;

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
