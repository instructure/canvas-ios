//
//  CKTextCommentInputView.h
//  CanvasKit
//
//  Created by BJ Homer on 9/16/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKStylingButton.h"

@interface CKTextCommentInputView : UIView

@property (nonatomic, weak) IBOutlet UITextView *inputCommentTextView;
@property (nonatomic, weak) IBOutlet CKStylingButton *postTextCommentButton;
@property (nonatomic, weak) IBOutlet CKStylingButton *flipToMediaCommentButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *textCommentActivityView;

@end
