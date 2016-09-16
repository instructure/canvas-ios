//
//  CBITextInputViewController.h
//  iCanvas
//
//  Created by derrick on 2/10/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <TBBModal/TBBModalViewController.h>
#import <CanvasKit1/CanvasKit1.h>

@interface CBISubmissionInputViewController : TBBModalViewController
@property (nonatomic) CKAssignment *assignment;
@property (nonatomic) CKCanvasAPI *canvasAPI;

@property (nonatomic, copy) void (^submissionCompletionBlock)(CKSubmission *submission, NSError *error);
@end
