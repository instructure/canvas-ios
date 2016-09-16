//
//  CBIMessagesListViewController.h
//  iCanvas
//
//  Created by Derrick Hathaway on 4/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

@import MyLittleViewController;
#import "CBIConversationStarter.h"
#import "CBIMessageViewModel.h"
#import "CBIMessagesListViewModel.h"

@interface CBIMessagesListViewController : MLVCTableViewController <CBIConversationStarter>
@property (nonatomic) CBIMessagesListViewModel *viewModel;
@end
