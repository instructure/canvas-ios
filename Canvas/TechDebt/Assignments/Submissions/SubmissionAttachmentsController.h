//
//  SubmissionAttachmentsController.h
//  iCanvas
//
//  Created by BJ Homer on 8/30/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKIFile;

@interface SubmissionAttachmentsController : UITableViewController

@property (nonatomic, strong) NSArray *attachments;
@property (nonatomic, strong) NSURL *liveURL;
@property (nonatomic, copy) BOOL (^attemptAnnotationsPreview)(CKIFile *, UIViewController *);
@property (copy) dispatch_block_t onTappedResubmit;

@property (weak) UIPopoverController *popoverController;
@property (weak) UIViewController *popoverPresenter;

@end
