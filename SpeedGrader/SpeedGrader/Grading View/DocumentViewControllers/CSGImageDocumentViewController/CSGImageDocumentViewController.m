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

#import "CSGImageDocumentViewController.h"
#import "UIImage+animatedGIF.h"
#import "CSGFileTypes.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

static NSString *const CSGLoadingImageName = @"user_image";

@interface CSGImageDocumentViewController ()

@property (nonatomic, strong) CKISubmissionRecord *submissionRecord;
@property (nonatomic, strong) CKISubmission *submission;
@property (nonatomic, strong) CKIFile *attachment;
@property (nonatomic, strong) NSURL *cachedAttachmentURL;

@property (nonatomic, strong) NSArray *supportedFileTypes;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation CSGImageDocumentViewController

#pragma mark - CSGDocumentHandler Protocol
+ (UIViewController *)instantiateFromStoryboard {
    CSGImageDocumentViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

+ (BOOL)canHandleSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment
{
    if ([submission isEqual:[NSNull null]]) {
        return NO;
    }
    
    if ([self isNotSubmission:submission] || [self isDummySubmission:submission]) {
        return NO;
    }
    
    return [self isOnlineURL:submission] &&
           [self isAcceptableOnlineUpload:submission attachment:attachment];
}

+ (UIViewController *)createWithSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    CSGImageDocumentViewController *imageDocumentViewController = (CSGImageDocumentViewController *)[self instantiateFromStoryboard];
    
    imageDocumentViewController.submissionRecord = submissionRecord;
    imageDocumentViewController.submission = submission;
    imageDocumentViewController.attachment = attachment;
    
    return imageDocumentViewController;
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

+ (BOOL)isOnlineURL:(CKISubmission *)submission
{
    return submission.type == CKISubmissionEnumTypeOnlineUpload;
}

+ (BOOL)isAcceptableOnlineUpload:(CKISubmission *)submission attachment:(CKIFile *)attachment
{
    if (submission.type == CKISubmissionEnumTypeOnlineUpload) {
        NSString *fileExtension = attachment.name.pathExtension;
        
        for (NSString *fileType in [self supportedFileTypes]) {
            if (fileType && [fileType compare:fileExtension options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return YES;
            }
        }
    }
    return NO;
}

+ (NSArray *)supportedFileTypes {
    return [CSGFileTypes supportedImageFileTypes];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.attachment) {
        DDLogInfo(@"SHOW IMAGE URL: %@", self.attachment.url);
        NSString *fileExtension = self.attachment.name.pathExtension;
        if ([fileExtension isEqualToString:CSGImageDocumentPathExtensionGIF]) {
            [self.imageView setImage:[UIImage imageNamed:CSGLoadingImageName]];
             
            @weakify(self);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *gifImage = [UIImage animatedImageWithAnimatedGIFURL:self.attachment.url];
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentVCFinishedLoading object:self];
                    [self.imageView setImage:gifImage];
                });
            });
        }
        else {
            // Don't need to weakify/strongify here because afnetworking nils out the blocks after calling them, breaking the cycle, pluse the vc never retains this block...
            [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:self.attachment.url] placeholderImage:[UIImage imageNamed:CSGLoadingImageName] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [self.imageView setImage:image];
                [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentVCFinishedLoading object:self];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentVCFinishedLoading object:self];
            }];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}


@end