//
//  CKAudioCommentRecorderViewInternal.h
//  CanvasKit
//
//  Created by BJ Homer on 9/2/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKAudioCommentRecorderView.h"
#import "INAVPlayerView.h"

@interface CKAudioCommentRecorderView () <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

// Main UI
@property (strong, nonatomic) IBOutlet UIView *mediaPanel;

@property (nonatomic, strong) IBOutlet UIView *mediaPanelHeadView;
// see public header for @property (nonatomic, strong) IBOutlet UIView *mediaPanelBaseView;

// LED panel
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UIImageView *ledMicImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ledRecordingImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ledReadyImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ledPlaybackImageView;

// Audio recording
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSString *recorderFilePath;
@property (nonatomic, strong) NSMutableDictionary *recorderSettings;
@property (nonatomic, assign) NSTimeInterval recordingDuration;


// IBActions
- (IBAction)tappedRecordButton:(id)sender;
- (IBAction)tappedPlayButton:(id)sender;

// Internal methods
//- (void)populateCaptureDevices;

- (BOOL)recordAudioComment;
- (void)stopRecordingAudioComment;

- (BOOL)playAudioComment;
- (void)stopPlayingAudioComment;

@end