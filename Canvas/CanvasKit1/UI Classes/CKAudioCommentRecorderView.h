//
//  CKAudioCommentRecorderView.h
//  CanvasKit
//
//  Created by BJ Homer on 9/1/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CanvasKit1/CKStylingButton.h>

@interface CKAudioCommentRecorderView : UIView

@property (weak, nonatomic, readonly) NSURL *recordedFileURL;
@property (nonatomic, weak) IBOutlet UIView *mediaPanelBaseView;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;

// Hidden by default, use at will
@property (weak, nonatomic) IBOutlet CKStylingButton *leftButton;
@property (weak, nonatomic) IBOutlet CKStylingButton *rightButton;

- (id)init;
- (void)stopAllMedia;
- (void)clearRecordedMedia;
@end
