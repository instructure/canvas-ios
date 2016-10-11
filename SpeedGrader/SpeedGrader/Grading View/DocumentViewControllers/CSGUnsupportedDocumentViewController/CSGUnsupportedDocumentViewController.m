//
//  CSGUnsupportedDocumentViewController.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 11/4/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGUnsupportedDocumentViewController.h"

@interface CSGUnsupportedDocumentViewController ()

@property (nonatomic, strong) CKISubmissionRecord *submissionRecord;
@property (nonatomic, strong) CKISubmission *submission;
@property (nonatomic, strong) CKIFile *attachment;
@property (nonatomic, strong) NSURL *cachedAttachmentURL;

@property (nonatomic, weak) IBOutlet UILabel *unsupportedSubmissionLabel;

@end

@implementation CSGUnsupportedDocumentViewController

#pragma mark - CSGDocumentHandler Protocol
+ (UIViewController *)instantiateFromStoryboard {
    CSGUnsupportedDocumentViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

+ (BOOL)canHandleSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment
{
    if ([submission isEqual:[NSNull null]]) {
        return NO;
    }
    
    return YES;
}

+ (UIViewController *)createWithSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    CSGUnsupportedDocumentViewController *unsupportedDocumentViewController = (CSGUnsupportedDocumentViewController *)[self instantiateFromStoryboard];
    
    unsupportedDocumentViewController.submissionRecord = submissionRecord;
    unsupportedDocumentViewController.submission = submission;
    unsupportedDocumentViewController.attachment = attachment;
    
    return unsupportedDocumentViewController;
}

#pragma mark - Can Handle Submission attachment

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DDLogInfo(@"SUBMISSION NOT SUPPORTED: UserID %@ \nSubmissionID %@ (%@)", self.submission.userID, self.submission.id, self.submission.url);
    self.unsupportedSubmissionLabel.text = NSLocalizedString(@"File Type Not Supported in Speedgrader iPad", @"No Submission Text");
    self.unsupportedSubmissionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.unsupportedSubmissionLabel.textColor = [UIColor lightGrayColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

@end
