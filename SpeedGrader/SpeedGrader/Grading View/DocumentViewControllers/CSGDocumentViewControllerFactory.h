//
// CSGDocumentViewController.h
// Created by Jason Larsen on 5/12/14.
//

#import <Foundation/Foundation.h>
#import "CSGDocumentHandler.h"

@class CANDSubmission;

/**
* Creates a view controller to manage and display a view for a document.
* A document is one piece of a submission. This piece may be
*/
@interface CSGDocumentViewControllerFactory: NSObject

+ (BOOL)canHandleSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment;
+ (Class)viewControllerClassForHandlingSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment;
+ (UIViewController<CSGDocumentHandler> *)createViewControllerForHandlingSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment;
+ (UIViewController *)createViewControllerForHandlingError;

@end