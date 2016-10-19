//
//  CBIMessagesSplitViewController.m
//  iCanvas
//
//  Created by derrick on 11/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIMessagesSplitViewController.h"
#import "CBIMessagesListViewModel.h"
#import "CBIMessageComposeMessageViewModel.h"
@import MyLittleViewController;
#import "CBIMessageDetailViewController.h"
@import ReactiveCocoa;
#import "UIViewController+Transitions.h"
#import "Router+Routes.h"
#import "CBIMessageParticipantsViewModel.h"
#import "CBIMessagesListViewController.h"
#import "UIImage+TechDebt.h"

@interface CBIMessagesSplitViewController ()
@property (nonatomic) UINavigationController *master;
@end

@implementation CBIMessagesSplitViewController
@synthesize viewModel;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupMasterDetail];
        self.title = NSLocalizedString(@"Messages", @"Title for the messages screen");
    }
    return self;
}

- (void)setupMasterDetail
{
    self.navigationController.tabBarItem.selectedImage = [UIImage techDebtImageNamed:@"icon_messages_tab_selected"];
    
    CBIMessagesListViewController *messages = [CBIMessagesListViewController new];
    self.viewModel = messages.viewModel;
    
    CBIMessageDetailViewController *messageDetail = [CBIMessageDetailViewController new];
    messageDetail.viewModel = [CBIMessageViewModel new];
    
    self.master = [[UINavigationController alloc] initWithRootViewController:messages];
    CGRect frame = self.master.view.frame;
    frame.size.height -= 64.f;
    frame.origin.y += 64.f;
    self.master.view.frame = frame;
    
    self.detail = messageDetail;
}

- (void)startAConversationWithRecipients:(NSArray *)conversationRecipients
{
    [self setupMasterDetail];
    [[self.master.viewControllers firstObject] startAConversationWithRecipients:conversationRecipients];
}

@end
