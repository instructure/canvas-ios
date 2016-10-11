//
//  AudioRecorderView.h
//  SpeedGrader
//
//  Created by Rick Roberts on 11/13/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AudioRecorderViewDelegate;

typedef NS_ENUM(NSUInteger, CSGAudioRecordingState) {
    CSGAudioRecordingStart,
    CSGAudioRecordingStop,
    CSGAudioRecordingPlay,
    CSGAudioRecordingPause
};

@interface AudioRecorderView : UIView

@property (nonatomic, weak) id <AudioRecorderViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UIImageView *audioActivityStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *audioActivityStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *audioActivityIndicator;

- (void)audioDeleteRecording;

@end

@protocol AudioRecorderViewDelegate <NSObject>

@optional

- (void)audioStartedRecording;
- (void)audioFinishedRecording;
- (void)audioDeleteRecording;
- (void)audioPlaybackRecording;
- (void)audioPauseRecording;
- (void)postAudio:(NSURL *)audioURL;

@end
