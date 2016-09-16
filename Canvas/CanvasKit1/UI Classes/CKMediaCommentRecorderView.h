//
//  CKMediaCommentRecorderView.h
//  CanvasKit
//
//  Created by BJ Homer on 9/1/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKStylingButton.h"

typedef enum {
    CKMediaCommentModeAudio = 1,
    CKMediaCommentModeVideo = 2
} CKMediaCommentMode;

@interface CKMediaCommentRecorderView : UIView

@property CKMediaCommentMode mode;
- (void)setMode:(CKMediaCommentMode)mode animated:(BOOL)animated;

@property (weak, nonatomic, readonly) NSURL *recordedFileURL;
@property (nonatomic, readonly, strong) CKStylingButton *flipToTextCommentButton;
@property (nonatomic, readonly, strong) CKStylingButton *postMediaCommentButton;


- (id)init;
- (void)rotateVideoToOrientation:(UIInterfaceOrientation)orientation;
- (void)stopAllMedia;
- (IBAction)tappedDonePlayingVideoButton:(id)sender;

- (void)clearRecordedMedia;

@end
