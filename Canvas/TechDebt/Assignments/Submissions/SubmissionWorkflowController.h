//
//  SubmissionWorkflowController.h
//  iCanvas
//
//  Created by BJ Homer on 4/24/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKAssignment, CKSubmission, CKCanvasAPI, CKContextInfo, CKIAssignment;

@interface SubmissionWorkflowController : NSObject

- (id)initWithViewController:(UIViewController *)viewController;
- (void)present;

@property CKCanvasAPI *canvasAPI;
@property CKIAssignment *assignment;
@property CKAssignment *legacyAssignment;
@property CKContextInfo *contextInfo;
@property (weak, readonly) UIViewController *viewController;

typedef void (^UploadProgressBlock)(float progress); // progress is -1 if indeterminate, else 0..1
typedef void (^UploadCompleteBlock)(CKSubmission *submission, NSError *error);

@property (copy) UploadProgressBlock uploadProgressBlock;
@property (copy) UploadCompleteBlock uploadCompleteBlock;
@property (nonatomic, assign) BOOL allowsMediaSubmission;


@end
