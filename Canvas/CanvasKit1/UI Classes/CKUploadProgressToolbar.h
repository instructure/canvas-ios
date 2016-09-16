//
//  CKUploadProgressToolbar.m
//  CanvasKit
//
//  Created by BJ Homer on 5/25/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKUploadProgressToolbar : UIView

@property (copy) NSString *uploadCompleteText;
@property (copy) NSString *uploadInProgressText;
@property (copy) NSString *cancelText;

// Clients set this to add a cancel button
@property (nonatomic, copy) void (^cancelBlock) ();

+ (CGFloat)preferredHeight;

- (void)cancel;
- (void)updateProgressViewWithProgress:(float)progress;
- (void)updateProgressViewWithIndeterminateProgress;
- (void)transitionToUploadCompletedWithError:(NSError *)error completion:(dispatch_block_t)completion;
- (void)showMessage:(NSString *)message;
- (void)hideMessageWithCompletionBlock:(dispatch_block_t)completionBlock;

@end
