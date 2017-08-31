//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import "CKMediaCommentRecorderView.h"
#import "INAVPlayerView.h"

@interface CKMediaCommentRecorderView () <AVAudioPlayerDelegate, AVAudioRecorderDelegate, AVCaptureFileOutputRecordingDelegate>

// Main UI
@property (strong, nonatomic) IBOutlet UIView *mediaPanel;

@property (nonatomic, strong) IBOutlet CKStylingButton *postMediaCommentButton;
@property (nonatomic, strong) IBOutlet CKStylingButton *flipToTextCommentButton;
@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIView *inputSelectionView;
@property (nonatomic, strong) IBOutlet UIButton *inputSelectionBackground;
@property (nonatomic, strong) IBOutlet UIButton *inputSelectionKnob;
@property (nonatomic, strong) IBOutlet UIView *mediaPanelHeadView;
@property (nonatomic, strong) IBOutlet UIView *mediaPanelBaseView;

// LED panel
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UIImageView *ledMicImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ledCameraImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ledRecordingImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ledReadyImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ledPlaybackImageView;

// Video panel UI
@property (nonatomic, strong) IBOutlet INAVPlayerView *videoPreviewView;
@property (nonatomic, strong) IBOutlet UIButton *switchCameraButton;
@property (nonatomic, strong) IBOutlet CKStylingButton *donePlayingVideoButton;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

// Video Recording
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *frontCamera;
@property (nonatomic, strong) AVCaptureDevice *rearCamera;
@property (nonatomic, strong) NSURL *videoRecorderFileURL;
@property (nonatomic, strong) AVCaptureMovieFileOutput *videoFileOutput;
@property (nonatomic) NSTimeInterval videoRecordingDuration;

// Audio recording
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSString *recorderFilePath;
@property (nonatomic, strong) NSMutableDictionary *recorderSettings;
@property (nonatomic, assign) NSTimeInterval recordingDuration;

// Video playback
@property (nonatomic, strong) INAVPlayerView *videoPlaybackView;
@property (nonatomic, strong) AVPlayer *videoPlayer;
@property (strong) AVPlayerItem *videoPlayerItem;


// IBActions
- (IBAction)tappedInputSelectionSwitch:(id)sender;
- (IBAction)tappedRecordButton:(id)sender;
- (IBAction)tappedPlayButton:(id)sender;
- (IBAction)tappedSwitchCameraButton:(id)sender;

// Internal methods
- (void)moveInputSelectionToMode:(CKMediaCommentMode)toMode animated:(BOOL)animated;
- (void)layoutVideoPreviewViewAnimated:(BOOL)animated;
- (void)setMode:(CKMediaCommentMode)newMode animated:(BOOL)animated;
- (void)changeToAudioMode:(BOOL)animated;
- (void)changeToVideoMode:(BOOL)animated;
- (void)stopVideoPreviewView;
- (void)populateCaptureDevices;

- (void)setUpVideoRecording;
- (BOOL)recordVideoComment;
- (void)stopRecordingVideoComment;

- (void)setUpVideoPlayback:(BOOL)resuming;
- (BOOL)playVideoComment;
- (void)stopPlayingVideoComment;
- (void)cleanUpAfterPlayingVideo;

- (BOOL)recordAudioComment;
- (void)stopRecordingAudioComment;

- (BOOL)playAudioComment;
- (void)stopPlayingAudioComment;

- (NSTimeInterval)videoPlayerCurrentTime;

@end