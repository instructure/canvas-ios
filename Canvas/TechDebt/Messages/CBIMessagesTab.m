//
//  CBIMessagesTab.m
//  iCanvas
//
//  Created by Derrick Hathaway on 5/9/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
