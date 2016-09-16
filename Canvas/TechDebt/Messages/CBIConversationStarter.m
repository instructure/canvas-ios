//
//  CBIConversationStarter.m
//  iCanvas
//
//  Created by derrick on 2/26/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIConversationStarter.h"
#import "CBIMessageViewModel.h"
#import "CBIMessageParticipantsViewModel.h"
#import "CBIMessageDetailViewController.h"
#import "UIViewController+Transitions.h"

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
    for (UINavigationController *nav in tabBar.viewControllers) {
        if ([nav.tabBarItem.title isEqualToString:NSLocalizedString(@"Messages", @"The name of the messages tab")]) {
            tabBar.selectedIndex = index;
            UIViewController<CBIConversationStarter> *root = [nav.viewControllers firstObject];
            [root startAConversationWithRecipients:conversationRecipients];
        }
        ++index;
    };
}

@end
