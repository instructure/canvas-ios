//
//  CSGErrorDocumentViewController.m
//  SpeedGrader
//
//  Created by Nathan Lambson on 5/20/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import "CSGErrorDocumentViewController.h"

@interface CSGErrorDocumentViewController ()

@property (nonatomic, strong) CKISubmissionRecord *submissionRecord;
@property (nonatomic, strong) CKISubmission *submission;
@property (nonatomic, strong) CKIFile *attachment;
@property (nonatomic, strong) NSURL *cachedAttachmentURL;

@end

@implementation CSGErrorDocumentViewController

#pragma mark - CSGDocumentHandler Protocol
+ (instancetype)instantiateFromStoryboard {
    CSGErrorDocumentViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

+ (BOOL)canHandleSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment
{
    return YES;
}

+ (UIViewController *)createWithSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    CSGErrorDocumentViewController *errorDocumentViewController = (CSGErrorDocumentViewController *)[self instantiateFromStoryboard];
    
    errorDocumentViewController.submissionRecord = submissionRecord;
    errorDocumentViewController.submission = submission;
    errorDocumentViewController.attachment = attachment;
    
    return errorDocumentViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = [UIImage imageNamed:@"panda_superman"];
    
    self.errorMessage.backgroundColor = [UIColor clearColor];
    self.errorMessage.font = [UIFont systemFontOfSize:24.0f];
    self.errorMessage.text = NSLocalizedString(@"Well, this was unexpected. We'll get SuperPanda on it.", @"Generic error message for routing");
    
    if ([self.submissionRecord isEqual:[NSNull null]] || [self.submission isEqual:[NSNull null]] || [self.attachment isEqual:[NSNull null]]) {
        self.errorMessage.text = NSLocalizedString(@"Well, this was unexpected. If this continues please contact your support representative.", @"Error message for corrupted server data");
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

@end
