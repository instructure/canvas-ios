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
