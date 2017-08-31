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
    
    

#import "CBIConversationStarter.h"
#import "CBIMessageViewModel.h"
#import "CBIMessageParticipantsViewModel.h"
#import "CBIMessageDetailViewController.h"

@implementation CBIConversationStarter

+ (instancetype)sharedConversationStarter
{
    static CBIConversationStarter *convoStarter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        convoStarter = [self new];
    });
    return convoStarter;
}

- (void)startAConversationWithRecipients:(NSArray *)conversationRecipients
{
    UITabBarController *tabBar = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    NSAssert([tabBar isKindOfClass:[UITabBarController class]], @"I thought we all agreed on UITabBarController!");
    NSInteger index = 0;
    for (UIViewController *tabVC in tabBar.viewControllers) {
        if ([tabVC.tabBarItem.title isEqualToString:NSLocalizedString(@"Messages", @"Title for the messages screen")] && [tabVC isKindOfClass:[UISplitViewController class]]) {
            tabBar.selectedIndex = index;
            UINavigationController *nav = [((UISplitViewController *)tabVC).viewControllers firstObject];
            UIViewController<CBIConversationStarter> *root = [nav.viewControllers firstObject];
            [root startAConversationWithRecipients:conversationRecipients];
        }
        ++index;
    };
}

@end
