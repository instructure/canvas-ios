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
