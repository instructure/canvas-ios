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

#import <Foundation/Foundation.h>

static NSString *const kDocumentVCFinishedLoading = @"document_vc_finished_loading";
static NSString *const kDocumentVCShouldCaptureTouch = @"document_vc_should_capture_touch";
static NSString *const kDocumentVCShouldNotCaptureTouch = @"document_vc_should_not_capture_touch";

@class CKISubmissionRecord;
@class CKISubmission;
@class CKIFile;

@protocol CSGDocumentHandler

+ (BOOL)canHandleSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment;
+ (UIViewController<CSGDocumentHandler> *)createWithSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment;
+ (UIViewController *)instantiateFromStoryboard;

- (void)setSubmissionRecord:(CKISubmissionRecord *)submissionRecord;
- (CKISubmissionRecord *)submissionRecord;

- (void)setSubmission:(CKISubmission *)submission;
- (CKISubmission *)submission;

- (void)setAttachment:(CKIFile *)attachment;
- (CKIFile *)attachment;

- (void)setCachedAttachmentURL:(NSURL *)url;
- (NSURL *)cachedAttachmentURL;

@optional

- (NSArray *)additionalBarButtons;

@end