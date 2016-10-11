//
//  VideoRecorderView.h
//  SpeedGrader
//
//  Created by Rick Roberts on 11/13/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideoRecorderViewDelegate;

@interface VideoRecorderView : UIView

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *videoPostButton;
@property (weak, nonatomic) IBOutlet UIImageView *videoStatusActivityImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoStatusActivityLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *videoStatusActivityIndicator;

@property (nonatomic, weak) id <VideoRecorderViewDelegate> delegate;

- (void)deleteVideo;

@end

@protocol VideoRecorderViewDelegate <NSObject>

@optional

- (void)videoStartedRecording;
- (void)videoDeletedRecording;
- (void)videoFinishedRecording;
- (void)postVideo:(NSURL *)videoURL;

@end
