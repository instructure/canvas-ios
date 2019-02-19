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
#import "CKMediaCommentRecorderViewInternal.h"
#import "INAVPlayerView.h"
#import "UIImage+CanvasKit1.h"
#import "UIAlertController+TechDebt.h"

static const NSString *ItemStatusContext;

#pragma mark -

@implementation CKMediaCommentRecorderView
@synthesize mode;

// Main UI
@synthesize mediaPanel;
@synthesize postMediaCommentButton;
@synthesize flipToTextCommentButton;
@synthesize recordButton;
@synthesize playButton;
@synthesize inputSelectionView;
@synthesize inputSelectionBackground;
@synthesize inputSelectionKnob;
@synthesize mediaPanelHeadView;
@synthesize mediaPanelBaseView;

// LED UI
@synthesize timeLabel;
@synthesize ledMicImageView;
@synthesize ledCameraImageView;
@synthesize ledRecordingImageView;
@synthesize ledReadyImageView;
@synthesize ledPlaybackImageView;

// Video panel UI
@synthesize videoPreviewView;
@synthesize switchCameraButton;
@synthesize donePlayingVideoButton;
@synthesize previewLayer;

// Audio recording
@synthesize recorder;
@synthesize audioPlayer;
@synthesize recorderFilePath;
@synthesize recorderSettings;
@synthesize recordingDuration;

// Video playback
@synthesize videoPlaybackView;
@synthesize videoPlayer;
@synthesize videoPlayerItem;

// Video recording
@synthesize captureSession;
@synthesize frontCamera;
@synthesize rearCamera;
@synthesize videoRecorderFileURL;
@synthesize videoFileOutput;
@synthesize videoRecordingDuration;

#pragma mark -
- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 360, 165)];
    if (self) {
        // Load subviews from a xib; it's easier
        [[UINib nibWithNibName:@"MediaCommentView" bundle:[NSBundle bundleForClass:[self class]]] instantiateWithOwner:self options:nil];
        
        mediaPanel.frame = self.bounds;
        [self addSubview:mediaPanel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.videoPlayer currentItem]];
        
        BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        self.inputSelectionView.hidden = !(hasCamera);
        self.ledCameraImageView.hidden = !(hasCamera);

        self.postMediaCommentButton.style = CKButtonStyleMediaComment;
        self.flipToTextCommentButton.style = CKButtonStyleMediaComment;
        
        self.donePlayingVideoButton.style = CKButtonStyleVideoOverlay;
        self.donePlayingVideoButton.titleLabel.text = NSLocalizedString(@"Done",nil);
        [self.donePlayingVideoButton.titleLabel sizeToFit];
        
        [self.postMediaCommentButton setTitle:NSLocalizedString(@"Post Comment",nil) forState:UIControlStateNormal];
        self.postMediaCommentButton.accessibilityLabel = NSLocalizedString(@"Post Comment", nil);
        self.postMediaCommentButton.accessibilityHint = NSLocalizedString(@"Posts your comment", nil);
        
        self.flipToTextCommentButton.accessibilityLabel = NSLocalizedString(@"Text Comment", nil);
        self.flipToTextCommentButton.accessibilityHint = NSLocalizedString(@"Switches to text comment mode", nil);
        
        self.recordButton.accessibilityLabel = NSLocalizedString(@"Record", @"A button that records");
        self.recordButton.accessibilityHint = NSLocalizedString(@"Starts recording a media comment", @"Hint about the record button");
        self.playButton.accessibilityLabel = NSLocalizedString(@"Play", @"A button that plays");
        self.playButton.accessibilityHint = NSLocalizedString(@"Starts playing your recording", @"Hint about the play button");
        
        if (hasCamera == NO) {
            [self setMode:CKMediaCommentModeAudio];
        }
        else {
            [self setMode:CKMediaCommentModeVideo];
        }
        
        // Slide these buttons down on the iPhone so they are visible.
        // TODO: If adding landscape support for this view, this will need to be altered
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            CGRect frame = self.switchCameraButton.frame;
            frame.origin.y += 35;
            self.switchCameraButton.frame = frame;
            
            frame = self.donePlayingVideoButton.frame;
            frame.origin.y += 35;
            self.donePlayingVideoButton.frame = frame;
        }
    }
    return self;
}

- (void)dealloc {
    if (self.videoPlayer) {
        [self cleanUpAfterPlayingVideo];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}


#pragma mark -
#pragma mark Modes

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.mode == CKMediaCommentModeVideo && self.superview != nil) {
        [self layoutVideoPreviewViewAnimated:YES];
    }
    if (self.superview == nil) {
        [self stopAllMedia];
    }

}


- (BOOL)inAudioMode
{
    return (self.mode == CKMediaCommentModeAudio);
}

- (BOOL)inVideoMode
{
    return (self.mode == CKMediaCommentModeVideo);
}

- (IBAction)tappedInputSelectionSwitch:(id)sender
{
    // Prevent the user from tapping the input selection again while the mode sets up
//    self.inputSelectionView.userInteractionEnabled = NO;
    
    // if mode is audio, animate the knob to the right and set mode
    if (CKMediaCommentModeAudio == self.mode) {
        [self setMode:CKMediaCommentModeVideo animated:(sender != self)];;
    }
    else {
        // if mode is video, animate the knob to the left and set mode
        [self setMode:CKMediaCommentModeAudio animated:YES];
    }
}

- (CKMediaCommentMode)mode {
    return mode;
}

- (void)setMode:(CKMediaCommentMode)mode_ {
    [self setMode:mode_ animated:(self.superview != nil)];
}

- (void)setMode:(CKMediaCommentMode)newMode animated:(BOOL)animated
{
    mode = newMode;
    
    [self moveInputSelectionToMode:newMode animated:animated];
    [self stopAllMedia];
    self.ledReadyImageView.highlighted = NO;
    
    
    // call the correct changeTo method
    if (CKMediaCommentModeAudio == newMode) {
        [self changeToAudioMode:animated];
    }
    else if (CKMediaCommentModeVideo == newMode) {
        [self changeToVideoMode:animated];
    }
    else {
        NSLog(@"Tried to set the media panel to an unknown mode: %i",newMode);
        return;
    }
    
    NSString *mediaTypeAccessibilityString = mode == CKMediaCommentModeAudio ? NSLocalizedString(@"Audio", @"Media type is audio") : NSLocalizedString(@"Video", @"Media type is video");
    self.inputSelectionView.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Media type selector. %@", @"A slider to choose between media types"),mediaTypeAccessibilityString];
    self.inputSelectionView.accessibilityHint = [NSString stringWithFormat:NSLocalizedString(@"Switches media input between audio and video. Currently set to %@", @"Hint about media input selection"),mediaTypeAccessibilityString];
}

- (NSURL *)recordedFileURL {
    if (mode == CKMediaCommentModeAudio && self.recorderFilePath) {
        return [NSURL fileURLWithPath:self.recorderFilePath];
    }
    else if (mode == CKMediaCommentModeVideo) {
        return self.videoRecorderFileURL;
    }
    else {
        return nil;
    }
}

- (void)moveInputSelectionToMode:(CKMediaCommentMode)toMode animated:(BOOL)animated
{
    CGRect destination = self.inputSelectionKnob.frame;
    UIView *inputTrackBackground = self.inputSelectionBackground;
    if (toMode == CKMediaCommentModeAudio) {
        destination.origin = inputTrackBackground.frame.origin;
    }
    else {
        CGFloat x = CGRectGetMaxX(inputTrackBackground.frame) - inputSelectionKnob.frame.size.width;
        destination.origin = CGPointMake(x, inputTrackBackground.frame.origin.y);
    }
    
    [UIView animateWithDuration:0.2 * animated animations:^(void) {
        self.inputSelectionKnob.frame = destination;
    }];
}

- (void)changeToAudioMode:(BOOL)animated
{
    // tear down video mode
    [self stopVideoPreviewView];
    if (self.videoPlayer) {
        [self cleanUpAfterPlayingVideo];
    }
    
    // todo: can probably remove this line. it prevents an infinite loop in stopAllMedia in the simulator, but isn't necessary on a device with a camera
    self.videoFileOutput = nil;
    
    // todo: find a more suitable way to determine if play should be enabled
    self.playButton.enabled = self.recorderFilePath ? YES : NO;
    
    [self layoutVideoPreviewViewAnimated:animated];
    
    // set up audio mode
    self.ledCameraImageView.highlighted = NO;
    self.ledMicImageView.highlighted = YES;
    self.ledReadyImageView.highlighted = YES;
}

- (void)changeToVideoMode:(BOOL)animated
{
    // tear down audio mode
    self.playButton.enabled = NO;
    
    [self layoutVideoPreviewViewAnimated:animated];
    
    if (self.videoRecorderFileURL) {
        [self setUpVideoPlayback:NO];
    }
    else {
        [self setUpVideoRecording];
    }
    
    self.ledMicImageView.highlighted = NO;
    self.ledCameraImageView.highlighted = YES;
}

- (void)layoutVideoPreviewViewAnimated:(BOOL)animated {
    CGSize baseSize = self.mediaPanelBaseView.bounds.size;
    CGSize headSize = self.mediaPanelHeadView.bounds.size;
    
    if (self.mode == CKMediaCommentModeAudio) {
        [UIView animateWithDuration:0.2 * animated
                         animations:^{
                             CGRect newFrame = self.frame;
                             newFrame.size = CGSizeMake(newFrame.size.width, baseSize.height + headSize.height);
                             self.frame = newFrame;
                         } completion:^(BOOL finished) {
                             [self.videoPreviewView removeFromSuperview];
                         }];
    }
    else {
        [UIView animateWithDuration:0.2 * animated
                         animations:^{
                             [self.mediaPanel insertSubview:videoPreviewView belowSubview:mediaPanelBaseView];
                             
                             CGRect previewFrame = self.videoPreviewView.frame;
                             previewFrame.origin.y = CGRectGetMaxY(self.mediaPanelHeadView.frame);
                             self.videoPreviewView.frame = previewFrame;
                             
                             CGSize previewSize = self.videoPreviewView.bounds.size;
                             CGRect newFrame = self.frame;
                             newFrame.size = CGSizeMake(newFrame.size.width,
                                                        baseSize.height + previewSize.height + headSize.height);
                             self.frame = newFrame;
                         }
                         completion:^(BOOL finished) {
                             self.ledReadyImageView.highlighted = YES;
                         }];
    }
}


- (CKMediaCommentMode)modeForCurrentKnobLocation
{
    // calculate where the knob is
    // get the left x of the input-selection-background image
    CGFloat backgroundLeftX = CGRectGetMinX(self.inputSelectionBackground.frame);
    // get the x of the center of the knob
    CGFloat knobCenterX = CGRectGetMidX(self.inputSelectionKnob.frame);
    // if the x is less than the left x plus the width of the knob, the knob is left
    if (knobCenterX < backgroundLeftX + self.inputSelectionKnob.frame.size.width) {
        // if it's on the left, return CKMediaCommentModeAudio
        return CKMediaCommentModeAudio;
    }
    else {
        // if it's on the right, return CKMediaCommentModeVideo
        return CKMediaCommentModeVideo;
    }
}

#pragma mark -
#pragma mark Handling Audio

- (IBAction)tappedRecordButton:(CKStylingButton *)sender {
    if ([self inAudioMode]) {
        if (!self.recorder) {
            // Stop the player if it is currently playing
            [self stopAllMedia];
            
            if ([self recordAudioComment]) {
                self.ledRecordingImageView.highlighted = YES;
                self.ledReadyImageView.highlighted = NO;
                [self.recordButton setImage:[UIImage canvasKit1ImageNamed:@"button-stop-recording"] forState:UIControlStateNormal];
                self.playButton.enabled = YES;
                self.postMediaCommentButton.enabled = YES;
                self.recordButton.accessibilityLabel = NSLocalizedString(@"Stop", @"A button that stops");
                self.recordButton.accessibilityHint = NSLocalizedString(@"Stops recording a media comment", @"Hint about the record button");
            }
        }
        else {
            [self.recordButton setImage:[UIImage canvasKit1ImageNamed:@"button-record"] forState:UIControlStateNormal];
            [self stopRecordingAudioComment];
            self.ledRecordingImageView.highlighted = NO;
            self.ledReadyImageView.highlighted = YES;
            self.recordButton.accessibilityLabel = NSLocalizedString(@"Record", @"A button that records");
            self.recordButton.accessibilityHint = NSLocalizedString(@"Starts recording a media comment", @"Hint about the record button");
        }
    }
    else if ([self inVideoMode]) {
        if (!self.videoFileOutput) {
            // Stop the player if it is currently playing
            [self stopAllMedia];
            
            if (!self.captureSession) {
                [self setUpVideoRecording];
            }
            
            if ([self recordVideoComment]) {
                self.ledRecordingImageView.highlighted = YES;
                self.ledReadyImageView.highlighted = NO;
                [self.recordButton setImage:[UIImage canvasKit1ImageNamed:@"button-stop-recording"] forState:UIControlStateNormal];
                self.playButton.enabled = NO;
                self.postMediaCommentButton.enabled = YES;
                self.recordButton.accessibilityLabel = NSLocalizedString(@"Stop", @"A button that stops");
                self.recordButton.accessibilityHint = NSLocalizedString(@"Stops recording a media comment", @"Hint about the record button");
            }
        }
        else {
            [self.recordButton setImage:[UIImage canvasKit1ImageNamed:@"button-record"] forState:UIControlStateNormal];
            [self stopRecordingVideoComment];
            self.ledRecordingImageView.highlighted = NO;
            self.ledReadyImageView.highlighted = YES;
            self.recordButton.accessibilityLabel = NSLocalizedString(@"Record", @"A button that records");
            self.recordButton.accessibilityHint = NSLocalizedString(@"Starts recording a media comment", @"Hint about the record button");
        }
    }
}

- (IBAction)tappedPlayButton:(CKStylingButton *)sender {
    if ([self inAudioMode]) {
        if (!audioPlayer) {
            // Stop the recorder if it is currently recording
            [self stopAllMedia];
            
            if ([self playAudioComment]) {
                self.ledPlaybackImageView.highlighted = YES;
                self.ledReadyImageView.highlighted = NO;
                [self.playButton setImage:[UIImage canvasKit1ImageNamed:@"button-stop-playback"] forState:UIControlStateNormal];
                self.playButton.accessibilityLabel = NSLocalizedString(@"Stop", @"A button that stops");
                self.playButton.accessibilityHint = NSLocalizedString(@"Stops playing your recording", @"Hint about the play button");
            }
        }
        else {
            [self stopPlayingAudioComment];
            [self.playButton setImage:[UIImage canvasKit1ImageNamed:@"button-play"] forState:UIControlStateNormal];
            self.ledPlaybackImageView.highlighted = NO;
            self.ledReadyImageView.highlighted = YES;
            self.playButton.accessibilityLabel = NSLocalizedString(@"Play", @"A button that plays");
            self.playButton.accessibilityHint = NSLocalizedString(@"Starts playing your recording", @"Hint about the play button");
        }
    }
    else if ([self inVideoMode]) {
        if ([self.videoPlayer rate] == 0) {
            if ([self playVideoComment]) {
                self.ledPlaybackImageView.highlighted = YES;
                self.ledReadyImageView.highlighted = NO;
                [self.playButton setImage:[UIImage canvasKit1ImageNamed:@"button-stop-playback"] forState:UIControlStateNormal];
                self.playButton.accessibilityLabel = NSLocalizedString(@"Stop", @"A button that stops");
                self.playButton.accessibilityHint = NSLocalizedString(@"Stops playing your recording", @"Hint about the play button");
            }
        }
        else {
            [self stopPlayingVideoComment];
            [self.playButton setImage:[UIImage canvasKit1ImageNamed:@"button-play"] forState:UIControlStateNormal];
            self.ledPlaybackImageView.highlighted = NO;
            self.ledReadyImageView.highlighted = YES;
            self.playButton.accessibilityLabel = NSLocalizedString(@"Play", @"A button that plays");
            self.playButton.accessibilityHint = NSLocalizedString(@"Starts playing your recording", @"Hint about the play button");
        }
    }
}

- (void)stopAllMedia
{
    // This method is used to stop the recorder and player if they are currently working
    if (self.audioPlayer) {
        [self tappedPlayButton:self.playButton];
    }
    
    if (self.recorder) {
        [self tappedRecordButton:self.recordButton];
    }
    
    if (self.videoFileOutput) {
        [self tappedRecordButton:self.recordButton];
    }
    
    if (self.videoPlayer && [self.videoPlayer rate] > 0) {
        [self tappedPlayButton:self.playButton];
    }
}

- (BOOL)recordAudioComment
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return NO;
    }
    err = nil;
    [audioSession setActive:YES error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return NO;
    }
    
    recorderSettings = [[NSMutableDictionary alloc] init];
    
    // TODO: Convert the file before sending?
    // We can tweak these settings to adjust quality and file size
    [recorderSettings setValue:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [recorderSettings setValue:@22050.0f forKey:AVSampleRateKey]; 
    [recorderSettings setValue:@2 forKey:AVNumberOfChannelsKey];
    
    [recorderSettings setValue :@16 forKey:AVLinearPCMBitDepthKey];
    [recorderSettings setValue :@NO forKey:AVLinearPCMIsBigEndianKey];
    [recorderSettings setValue :@NO forKey:AVLinearPCMIsFloatKey];
    
    // Create a new dated file
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    self.recorderFilePath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:caldate] stringByAppendingPathExtension:@"wav"];
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recorderSettings error:&err];
    if(!self.recorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        [UIAlertController showAlertWithTitle:NSLocalizedString(@"Warning", nil) message:[err localizedDescription]];
        self.recorderFilePath = nil;
        return NO;
    }
    
    //prepare to record
    [self.recorder setDelegate:self];
    [self.recorder prepareToRecord];
    
    BOOL audioHWAvailable = audioSession.inputAvailable;
    if (! audioHWAvailable) {
        [UIAlertController showAlertWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"Audio input hardware not available",nil)];
        self.recorder = nil;
        self.recorderFilePath = nil;
        return NO;
    }
    
    self.recordingDuration = 0.0;
    [self performSelector:@selector(updateRecordTime:) withObject:nil afterDelay:0.05];
    
    // start recording
    // TODO this line causes the UI to hang for a few seconds on the first run. figure out a way around it
    [self.recorder record];
    return YES;
}

- (void)updateRecordTime:(id)obj
{
    if (self.recorder) {
        self.timeLabel.text = [NSString stringWithFormat:@"%.2f", self.recorder.currentTime];
        self.recordingDuration = self.recorder.currentTime;
        
        if (self.recorder.recording) {
            [self performSelector:@selector(updateRecordTime:) withObject:nil afterDelay:0.05];
        }
    }
    
    if (self.audioPlayer) {
        self.timeLabel.text = [NSString stringWithFormat:@"%.2f", self.audioPlayer.currentTime];
        
        if (self.audioPlayer.playing) {
            [self performSelector:@selector(updateRecordTime:) withObject:nil afterDelay:0.05];
        }
    }
    
    if (self.videoFileOutput && !self.videoPlayer && obj == self.videoFileOutput) {
        self.videoRecordingDuration += 0.05;
        self.timeLabel.text = [NSString stringWithFormat:@"%.2f", self.videoRecordingDuration];
        [self performSelector:@selector(updateRecordTime:) withObject:self.videoFileOutput afterDelay:0.05];
    }
    
    if (self.videoPlayer && [self.videoPlayer rate] > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%.2f", [self videoPlayerCurrentTime]];
        [self performSelector:@selector(updateRecordTime:) withObject:self.videoPlayer afterDelay:0.05];
    }
}

- (void)stopRecordingAudioComment {
    self.recordingDuration = self.recorder.currentTime;
    [self.recorder stop];
}

- (BOOL)playAudioComment
{
    if (!self.recorderFilePath) {
        // This means they haven't recorded anything yet
        return NO;
    }
    
    NSError *err = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.recorderFilePath] error:&err];
    if (err) {
        NSLog(@"error playing audio comment: %@ %ld %@",[err domain], (long)[err code], [[err userInfo] description]);
        self.audioPlayer = nil;
        return NO;
    }
    self.audioPlayer.delegate = self;
    [self.audioPlayer play];
    
    [self performSelector:@selector(updateRecordTime:) withObject:nil afterDelay:0.05];
    
    return YES;
}

- (void)stopPlayingAudioComment {
    [self.audioPlayer stop];
    [self audioPlayerDidFinishPlaying:self.audioPlayer successfully:YES];
}

#pragma mark -
#pragma mark AVAudio Delegates

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    NSLog(@"Audio finished recording with success of: %d at URL: %@",flag,self.recorderFilePath);
    self.recorder.delegate = nil;
    self.recorder = nil;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)aPlayer successfully:(BOOL)flag
{
    // todo: should really move this UI logic to a "syncUI" type method
    [self.playButton setImage:[UIImage canvasKit1ImageNamed:@"button-play"] forState:UIControlStateNormal];
    self.ledPlaybackImageView.highlighted = NO;
    self.ledReadyImageView.highlighted = YES;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%.2f", self.recordingDuration];
    self.audioPlayer.delegate = nil;
    self.audioPlayer = nil;
}


#pragma mark -
#pragma mark Video Recording

- (void)setUpVideoRecording
{
    if (!self.captureSession) {
        self.captureSession = [[AVCaptureSession alloc] init];
        self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        AVCaptureDevice *videoCaptureDevice = self.frontCamera != nil ? self.frontCamera : self.rearCamera;
        
        NSError *error = nil;
        
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
        if (videoInput) {
            [self.captureSession addInput:videoInput];
        }
        else {
            NSLog(@"There was an error using the video capture device input: %@",error);
        }
        
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:&error];
        if (audioInput) {
            [self.captureSession addInput:audioInput];
        }
        else {
            NSLog(@"There was an error using the audio capture device input: %@",error);
        }
        
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.frame = self.videoPreviewView.bounds;
        [self rotateVideoToOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        [self.videoPreviewView.layer insertSublayer:self.previewLayer below:self.switchCameraButton.layer];
    }
    
    // The session might already be running if the user temporarily hid the videoPreviewView
    if (![self.captureSession isRunning]) {
        [self.captureSession startRunning];
    }
    
    self.switchCameraButton.hidden = !(self.frontCamera && self.rearCamera);
}

- (void)rotateVideoToOrientation:(UIInterfaceOrientation)orientation
{
    if (![self.videoFileOutput isRecording]) {
        self.previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)orientation;
    }
    
    if (self.videoFileOutput && ![self.videoFileOutput isRecording]) {
        AVCaptureConnection *videoConnection = NULL;
        
        for (AVCaptureConnection *connection in [self.videoFileOutput connections]) {
            for (AVCaptureInputPort *port in [connection inputPorts]) {
                if ([[port mediaType] isEqual:AVMediaTypeVideo]) 
                {
                    videoConnection = connection;
                }
            }
        }
        
        if ([videoConnection isVideoOrientationSupported]) {
            [videoConnection setVideoOrientation:(AVCaptureVideoOrientation)orientation];
        }
    }
}

- (void)stopVideoPreviewView
{
    if (self.captureSession) {
        [self.previewLayer removeFromSuperlayer];
        self.previewLayer = nil;
        [self stopCaptureSession];
        self.switchCameraButton.hidden = YES;
    }
}

- (void)stopCaptureSession
{
    @autoreleasepool {
        if (self.captureSession) {
            [self.captureSession stopRunning];
            self.captureSession = nil;
        }
    }
}

- (IBAction)tappedSwitchCameraButton:(id)sender
{
    [self.recordButton setImage:[UIImage canvasKit1ImageNamed:@"button-record"] forState:UIControlStateNormal];
    self.ledRecordingImageView.highlighted = NO;
    self.ledReadyImageView.highlighted = YES;
    
    AVCaptureDevice *switchingToDevice = nil;
    // figure out if front or rear camera is currently being used
    for (AVCaptureDeviceInput *input in self.captureSession.inputs) {
        if (input.device == self.frontCamera) {
            switchingToDevice = self.rearCamera;
        }
        else if (input.device == self.rearCamera) {
            switchingToDevice = self.frontCamera;
        }
        
        // We remove all inputs and set them back up again below.
        [self.captureSession removeInput:input];
    }
    
    // switch over to the opposite camera with a transaction
    [self.captureSession beginConfiguration];
    
    // Add a new capture device.
    NSError *error = nil;
    AVCaptureDeviceInput *switchingToDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:switchingToDevice error:&error];
    if (switchingToDeviceInput) {
        [self.captureSession addInput:switchingToDeviceInput];
    }
    else {
        NSLog(@"There was an error switching to the video capture device input: %@",error);
    }
    
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:&error];
    if (audioInput) {
        [self.captureSession addInput:audioInput];
    }
    else {
        NSLog(@"There was an error using the audio capture device input: %@",error);
    }
    
    [self.captureSession commitConfiguration];
}

- (AVCaptureDevice *)frontCamera
{
    if (!frontCamera) {
        [self populateCaptureDevices];
    }
    
    return frontCamera;
}

- (AVCaptureDevice *)rearCamera
{
    if (!rearCamera) {
        [self populateCaptureDevices];
    }
    
    return rearCamera;
}

- (void)populateCaptureDevices
{
    AVCaptureDeviceDiscoverySession *session = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    
    for (AVCaptureDevice *device in session.devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device position] == AVCaptureDevicePositionFront) {
                self.frontCamera = device;
            }
            else if ([device position] == AVCaptureDevicePositionBack) {
                self.rearCamera = device;
            }
            else {
                NSLog(@"wtf, you have a third camera?");
            }
        }
    }
}

- (BOOL)recordVideoComment
{
    if (self.videoPlayer) {
        [self cleanUpAfterPlayingVideo];
    }
    
    self.videoFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.videoFileOutput]) {
        [self.captureSession addOutput:self.videoFileOutput];
    }
    else {
        NSLog(@"There was an error adding the video file output to the capture session.");
        self.videoFileOutput = nil;
        return NO;
    }
    
    // Create a new dated file
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:caldate] stringByAppendingPathExtension:@"mp4"];
    self.videoRecorderFileURL = [NSURL fileURLWithPath:filePath];
    //self.videoRecorderFileURL = [NSURL fileURLWithPath:@"/Users/mark/Movies/MyPants.mp4"]; // This is for testing playback and upload on a device without a camera
    
    [self rotateVideoToOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    self.videoRecordingDuration = 0;
    [self.videoFileOutput startRecordingToOutputFileURL:self.videoRecorderFileURL recordingDelegate:self];
    
    return YES;
}

- (void)stopRecordingVideoComment
{
    [self.videoFileOutput stopRecording];
    if (self.videoFileOutput) {
        [self.captureSession removeOutput:self.videoFileOutput];
        self.videoFileOutput = nil;
    }
    
    [self setUpVideoPlayback:NO];
}

#pragma mark -
#pragma mark Video Recording Delegates

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    [self performSelector:@selector(updateRecordTime:) withObject:self.videoFileOutput afterDelay:0.05];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    BOOL recordedSuccessfully = YES;
    if ([error code] != noErr) {
        // A problem occurred: Find out if the recording was successful.
        id value = [error userInfo][AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            recordedSuccessfully = [value boolValue];
        }
    }
    
    if (!recordedSuccessfully) {
        NSLog(@"The video recording failed with an error: %@",error);
        [self stopAllMedia];
        // notify the user of the error (probably with an alert)
        [UIAlertController showAlertWithTitle:NSLocalizedString(@"Video Error", nil) message:[error localizedDescription]];
    }
    
    [self.captureSession removeOutput:self.videoFileOutput];
    self.videoFileOutput = nil;
}

#pragma mark -
#pragma mark Video Playback

- (void)setUpVideoPlayback:(BOOL)resuming
{
    if (!self.videoRecorderFileURL) {
        // This means they haven't recorded anything yet
        return;
    }
    
    [self stopVideoPreviewView];
    
    NSURL *fileURL = self.videoRecorderFileURL;
    //NSURL *fileURL = [NSURL fileURLWithPath:@"/Users/mark/Movies/Nintendo.m4v"];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSString *tracksKey = @"tracks";
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
     ^{
         // The completion block goes here.
         // Define this constant for the key-value observation context.
         
         NSError *error = nil;
         
         AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
         
         if (status == AVKeyValueStatusLoaded) {
             self.videoPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
             [self.videoPlayerItem addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
             self.videoPlayer = [AVPlayer playerWithPlayerItem:self.videoPlayerItem];
             
             [(AVPlayerLayer *)self.videoPreviewView.layer setPlayer:self.videoPlayer];
             self.donePlayingVideoButton.hidden = NO;
             self.switchCameraButton.hidden = YES;
             if (resuming) {
                 // We are resuming playback of a file that has already been loaded for playback at least once.
                 // This happens when a user has tapped the Done button or has submitted the video comment.
                 [self tappedPlayButton:nil];
             }
         }
         else {   
             // Deal with the error appropriately.
             NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
         }
     }];
}

- (BOOL)playVideoComment
{
    // Get the status of the video player.
    //If the status is error or unknown,
    // return NO
    if (!self.videoPlayer) {
        NSLog(@"Tapped play, but the player is not ready to play yet.");
        // Set up the video playback. Since we're passing YES, it will tap the play button again for us when it's ready.
        [self setUpVideoPlayback:YES];
        return NO;
    }
    
    if (![(AVPlayerLayer *)self.videoPreviewView.layer player]) {
        [(AVPlayerLayer *)self.videoPreviewView.layer setPlayer:self.videoPlayer];
    }
    
    self.donePlayingVideoButton.hidden = NO;
    self.switchCameraButton.hidden = YES;
    [self.videoPlayer play];
    [self performSelector:@selector(updateRecordTime:) withObject:self.videoPlayer afterDelay:0.05];
    return YES;
}

- (void)stopPlayingVideoComment
{
    if ([self.videoPlayer rate] > 0) {
        [self.videoPlayer pause];
        [self.videoPlayer seekToTime:kCMTimeZero];
        self.timeLabel.text = [NSString stringWithFormat:@"%.2f", [self videoPlayerCurrentTime]];
    }
}

- (IBAction)tappedDonePlayingVideoButton:(id)sender
{
    [self stopAllMedia];
    
    [self.playButton setImage:[UIImage canvasKit1ImageNamed:@"button-play"] forState:UIControlStateNormal];
    self.ledPlaybackImageView.highlighted = NO;
    self.ledReadyImageView.highlighted = YES;
    self.donePlayingVideoButton.hidden = YES;
    
    [self cleanUpAfterPlayingVideo];
    
    [self setUpVideoRecording];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &ItemStatusContext) {
        if ((self.videoPlayer.currentItem != nil) && ([self.videoPlayer.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
            self.playButton.enabled = YES;
        }
        else {
            
        }
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    return;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self.videoPlayer seekToTime:kCMTimeZero];
    self.timeLabel.text = [NSString stringWithFormat:@"%.2f", [self videoPlayerCurrentTime]];
    [self.playButton setImage:[UIImage canvasKit1ImageNamed:@"button-play"] forState:UIControlStateNormal];
    self.ledPlaybackImageView.highlighted = NO;
    self.ledReadyImageView.highlighted = YES;
}

- (void)cleanUpAfterPlayingVideo
{
    [(AVPlayerLayer *)self.videoPreviewView.layer setPlayer:nil];
    [self.videoPlayerItem removeObserver:self forKeyPath:@"status"];
    self.videoPlayer = nil;
    self.videoPlayerItem = nil;
}

- (NSTimeInterval)videoPlayerCurrentTime
{
    CMTime currentTime = [self.videoPlayer currentTime];
    return (NSTimeInterval)((float)currentTime.value / (float)currentTime.timescale);
}

- (void)clearRecordedMedia {
    NSFileManager *manager = [NSFileManager new];
    if (self.recorderFilePath) {
        [manager removeItemAtPath:recorderFilePath error:NULL];
        recordingDuration = 0.0;
        self.recorderFilePath = nil;
    }
    if (self.videoRecorderFileURL) {
        [manager removeItemAtURL:videoRecorderFileURL error:NULL];
        videoRecordingDuration = 0.0;
        self.videoRecorderFileURL = nil;
    }
}



@end
