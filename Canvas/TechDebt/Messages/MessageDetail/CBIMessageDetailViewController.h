//
//  MessageDetailViewController.h
//  iCanvas
//
//  Created by derrick on 11/27/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import MyLittleViewController;
#import "CBIMessageViewModel.h"

@class CKAttachmentManager;
@interface CBIMessageDetailViewController : UITableViewController
@property (nonatomic) CBIMessageViewModel *viewModel;
@property (nonatomic) CKAttachmentManager *attachmentManager;
@end
