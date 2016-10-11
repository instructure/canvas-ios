//
// Created by Jason Larsen on 8/11/14.
// Copyright (c) 2014 Instructure. All rights reserved.
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