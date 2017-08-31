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
    
    

#import "CBIMessagesTab.h"
#import "CBIMessagesListViewModel.h"
#import "CBIMessagesListViewController.h"
#import "CBIMessageDetailViewController.h"
#import "UIImage+TechDebt.h"
@import SoPretty;

@implementation UIViewController (CBIMessagesTab)
+ (UIViewController *)messagesTab {
    SplitViewController *split = [[SplitViewController alloc] init];
    split.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;

    CBIMessagesListViewController *list = [[CBIMessagesListViewController alloc] init];
    UINavigationController *master = [[UINavigationController alloc] initWithRootViewController:list];
    CBIMessageDetailViewController *detail = [[CBIMessageDetailViewController alloc] init];
    detail.viewModel = [[CBIMessageViewModel alloc] init];
    UINavigationController *details = [[UINavigationController alloc] initWithRootViewController:detail];
    [split setViewControllers:@[master, details]];
    
    NSString *title = NSLocalizedString(@"Messages", comment: @"Title for the messages screen");
    list.title = title;
    split.tabBarItem.title = title;

    [list.viewModel badgeTabBarItem:split.tabBarItem];
    
    return split;
}
@end
