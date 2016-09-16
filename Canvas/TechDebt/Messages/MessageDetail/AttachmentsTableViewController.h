//
//  AttachmentsTableViewController.h
//  iCanvas
//
//  Created by Stephen Lottermoser on 5/10/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CKAttachmentManager;

@interface AttachmentsTableViewController : UITableViewController

@property (strong, nonatomic) CKAttachmentManager *attachmentManager;

@end
