//
//  CBISubmissionAnnotationPreviewHelper.h
//  iCanvas
//
//  Created by Ben Kraus on 11/11/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKIFile;

@interface CBISubmissionAnnotationPreviewHelper : NSObject

+ (BOOL)filePreviewableWithAnnotations:(CKIFile *)file;
+ (void)loadAnnotationPreviewForFile:(CKIFile *)file fromViewController:(UIViewController *)presentingViewController;

@end
