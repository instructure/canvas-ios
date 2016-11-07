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
#import "CBIMessagesSplitViewController.h"
#import "CBIMessagesListViewController.h"
#import "UIImage+TechDebt.h"
#import "UIImage+TechDebt.h"
#import "UIImage+TechDebt.h"

@implementation UIViewController (CBIMessagesTab)
+ (UIViewController *)messagesTab {
    UIViewController *vc;
    CBIMessagesListViewModel *vm;
    
    switch (UIDevice.currentDevice.userInterfaceIdiom) {
        case UIUserInterfaceIdiomPad: {
            CBIMessagesSplitViewController *split = [[CBIMessagesSplitViewController alloc] init];
            vc = split;
            vm = split.viewModel;
            break;
        }
        default: {
            CBIMessagesListViewController *list = [[CBIMessagesListViewController alloc] init];
            vc = list;
            vm = list.viewModel;
            break;
        }
    }
    
    NSString *title = NSLocalizedString(@"Messages", comment: @"Title for the messages screen");
    
    vc.title = title;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.tabBarItem.title = title;
    nav.tabBarItem.image = [UIImage techDebtImageNamed: @"icon_messages_tab"];
    nav.tabBarItem.selectedImage = [UIImage techDebtImageNamed: @"icon_messages_tab_selected"];
    
    [vm badgeTabBarItem:nav.tabBarItem];
    
    
    return nav;
}
@end
