//
//  CSGNoSubmissionDocumentViewController.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 11/4/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGNoSubmissionDocumentViewController.h"

@interface CSGNoSubmissionDocumentViewController ()

@property (nonatomic, strong) CKISubmissionRecord *submissionRecord;
@property (nonatomic, strong) CKISubmission *submission;
@property (nonatomic, strong) CKIFile *attachment;
@property (nonatomic, strong) NSURL *cachedAttachmentURL;

@property (nonatomic, weak) IBOutlet UILabel *noSubmissionLabel;

@end

@implementation CSGNoSubmissionDocumentViewController

#pragma mark - CSGDocumentHandler Protocol
+ (UIViewController *)instantiateFromStoryboard {
    CSGNoSubmissionDocumentViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

+ (BOOL)canHandleSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment
{
    if ([submission isEqual:[NSNull null]]) {
        return NO;
    }
    
    return [self isNotSubmission:submission] ||
    [self isDummySubmission:submission];
}

+ (UIViewController *)createWithSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    CSGNoSubmissionDocumentViewController *noSubmissionDocumentViewController = (CSGNoSubmissionDocumentViewController *)[self instantiateFromStoryboard];
    
    noSubmissionDocumentViewController.submissionRecord = submissionRecord;
    noSubmissionDocumentViewController.submission = submission;
    noSubmissionDocumentViewController.attachment = attachment;
    
    return noSubmissionDocumentViewController;
}

#pragma mark - Can Handle Submission attachment

+ (BOOL)isNotSubmission:(CKISubmission *)submission
{
    return !submission;
}

+ (BOOL)isDummySubmission:(CKISubmission *)submission
{
    return submission.attempt == 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DDLogInfo(@"NO SUBMISSION: UserID %@ \nSubmissionID %@ (%@)", self.submission.userID, self.submission.id, self.submission.url);
    
    self.noSubmissionLabel.text = NSLocalizedString(@"This student does not have a submission for this assignment", @"No Submission Text");
    self.noSubmissionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.noSubmissionLabel.textColor = [UIColor lightGrayColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentVCFinishedLoading object:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

@end
