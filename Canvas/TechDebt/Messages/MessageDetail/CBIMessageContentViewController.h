//
//  CBIMessageContentViewController.h
//  iCanvas
//
//  Created by derrick on 11/27/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "ConversationViewController.h"

@class CBIMessageViewModel;

@interface CBIMessageContentViewController : ConversationViewController
@property (nonatomic) CBIMessageViewModel *viewModel;
@property (nonatomic) BOOL hasLoadedConversation;
@end
