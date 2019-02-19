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
    
    

#import "CKAudioCommentRecorderView.h"
#import "CKAudioCommentRecorderViewInternal.h"
#import "INAVPlayerView.h"
#import "UIImage+CanvasKit1.h"
#import "UIAlertController+TechDebt.h"

#pragma mark -

@implementation CKAudioCommentRecorderView

// Main UI
@synthesize mediaPanel;
@synthesize recordButton;
@synthesize playButton;
@synthesize leftButton;
@synthesize rightButton;
@synthesize mediaPanelHeadView;
@synthesize mediaPanelBaseView;

// LED UI
@synthesize timeLabel;
@synthesize ledMicImageView;
@synthesize ledRecordingImageView;
@synthesize ledReadyImageView;
@synthesize ledPlaybackImageView;

// Audio recording
@synthesize recorder;
@synthesize audioPlayer;
@synthesize recorderFilePath;
@synthesize recorderSettings;
@synthesize recordingDuration;

#pragma mark -
- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 360, 165)];
    if (self) {
        // Load subviews from a xib; it's easier
        [[UINib nibWithNibName:@"AudioCommentView" bundle:[NSBundle bundleForClass:[self class]]] instantiateWithOwner:self options:nil];
        
        mediaPanel.frame = self.bounds;
        [self addSubview:mediaPanel];
    }
    return self;
}

#pragma mark -
#pragma mark Modes

- (void)layoutSubviews {
    [super layoutSubviews];
    leftButton.style = CKButtonStyleMediaComment;
    rightButton.style = CKButtonStyleMediaComment;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview == nil) {
        [self stopAllMedia];
    }
}

- (NSURL *)recordedFileURL {
    
    if (self.recorderFilePath) {
        return [NSURL fileURLWithPath:self.recorderFilePath];
    }
    return nil;
}

#pragma mark -
#pragma mark Handling Audio

- (IBAction)tappedRecordButton:(CKStylingButton *)sender {
    if (!self.recorder) {
        // Stop the player if it is currently playing
        [self stopAllMedia];
        
        if ([self recordAudioComment]) {
            self.ledRecordingImageView.highlighted = YES;
            self.ledReadyImageView.highlighted = NO;
            [self.recordButton setImage:[UIImage canvasKit1ImageNamed:@"button-stop-recording"] forState:UIControlStateNormal];
            self.playButton.enabled = YES;
        }
    }
    else {
        [self.recordButton setImage:[UIImage canvasKit1ImageNamed:@"button-record"] forState:UIControlStateNormal];
        [self stopRecordingAudioComment];
        self.ledRecordingImageView.highlighted = NO;
        self.ledReadyImageView.highlighted = YES;
    }
}

- (IBAction)tappedPlayButton:(CKStylingButton *)sender {
    if (!audioPlayer) {
        // Stop the recorder if it is currently recording
        [self stopAllMedia];
        
        if ([self playAudioComment]) {
            self.ledPlaybackImageView.highlighted = YES;
            self.ledReadyImageView.highlighted = NO;
            [self.playButton setImage:[UIImage canvasKit1ImageNamed:@"button-stop-playback"] forState:UIControlStateNormal];
        }
    }
    else {
        [self stopPlayingAudioComment];
        [self.playButton setImage:[UIImage canvasKit1ImageNamed:@"button-play"] forState:UIControlStateNormal];
        self.ledPlaybackImageView.highlighted = NO;
        self.ledReadyImageView.highlighted = YES;
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
        [UIAlertController showAlertWithTitle:NSLocalizedString(@"Warning",nil) message:[err localizedDescription]];
        recorderFilePath = nil;
        return NO;
    }
    
    //prepare to record
    [self.recorder setDelegate:self];
    [self.recorder prepareToRecord];
    
    BOOL audioHWAvailable = audioSession.inputAvailable;
    if (! audioHWAvailable) {
        [UIAlertController showAlertWithTitle:NSLocalizedString(@"Warning",nil) message:NSLocalizedString(@"Audio input hardware not available",nil)];
        self.recorder = nil;
        recorderFilePath = nil;
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

//- (void)stopCaptureSession
//{
//    @autoreleasepool {
//        if (self.captureSession) {
//            [self.captureSession stopRunning];
//            self.captureSession = nil;
//        }
//    }
//}


//- (void)populateCaptureDevices
//{
//    NSArray *devices = [AVCaptureDevice devices];
//    
//    for (AVCaptureDevice *device in devices) {
//        if ([device hasMediaType:AVMediaTypeVideo]) {
//            if ([device position] == AVCaptureDevicePositionFront) {
//                self.frontCamera = device;
//            }
//            else if ([device position] == AVCaptureDevicePositionBack) {
//                self.rearCamera = device;
//            }
//            else {
//                NSLog(@"wtf, you have a third camera?");
//            }
//        }
//    }
//}


//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if (context == &ItemStatusContext) {
//        if ((self.videoPlayer.currentItem != nil) && ([self.videoPlayer.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
//            self.playButton.enabled = YES;
//        }
//        else {
//            
//        }
//        return;
//    }
//    
//    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    return;
//}

//- (void)playerItemDidReachEnd:(NSNotification *)notification
//{
//    [self.videoPlayer seekToTime:kCMTimeZero];
//    self.timeLabel.text = [NSString stringWithFormat:@"%.2f", [self videoPlayerCurrentTime]];
//    [self.playButton setImage:[UIImage canvasKit1ImageNamed:@"button-play"] forState:UIControlStateNormal];
//    self.ledPlaybackImageView.highlighted = NO;
//    self.ledReadyImageView.highlighted = YES;
//}

- (void)clearRecordedMedia {
    NSFileManager *manager = [NSFileManager new];
    if (self.recorderFilePath) {
        [manager removeItemAtPath:recorderFilePath error:NULL];
        recordingDuration = 0.0;
    }
}


@end
