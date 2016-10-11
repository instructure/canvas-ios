//
//  CSGSubmissionViewController.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 11/10/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSGDocumentHandler.h"

@interface CSGSubmissionViewController : UIViewController

@property (nonatomic, strong) CKISubmissionRecord *submissionRecord;

@property (nonatomic, readonly) UIViewController<CSGDocumentHandler> *documentViewController;
@property (nonatomic, strong) CKISubmission *selectedSubmission;
@property (nonatomic, strong) CKIFile *selectedAttachment;

+ (instancetype)instantiateFromStoryboard;
- (void)reloadDocumentView;

@end
