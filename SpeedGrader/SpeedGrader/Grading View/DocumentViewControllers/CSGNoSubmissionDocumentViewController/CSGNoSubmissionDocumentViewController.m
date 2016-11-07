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
