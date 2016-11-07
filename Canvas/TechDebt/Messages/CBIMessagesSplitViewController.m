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
