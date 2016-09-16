//
//  CBIMessagesListViewController.m
//  iCanvas
//
//  Created by Derrick Hathaway on 4/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIMessagesListViewController.h"
#import "CBIMessageDetailViewController.h"
#import "CBIMessageParticipantsViewModel.h"
#import "UIViewController+Transitions.h"
#import "CBIMessagesSplitViewController.h"

@implementation CBIMessagesListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [CBIMessagesListViewModel new];
    }
    return self;
}

- (void)startAConversationWithRecipients:(NSArray *)conversationRecipients
{
    CBIMessageViewModel *newMessage = [CBIMessageViewModel new];
    newMessage.participantsViewModel.pendingRecipients = conversationRecipients;
    CBIMessageDetailViewController *detail = [CBIMessageDetailViewController new];
    detail.viewModel = newMessage;
    
    // replace what was already there.
    self.navigationController.viewControllers = @[self];
    
    [self cbi_transitionToViewController:detail animated:NO];
}

@end
