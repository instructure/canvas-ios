//
//  VideoManager.m
//  SpeedGrader
//
//  Created by Rick Roberts on 11/11/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "VideoManager.h"

static const NSString *ItemStatusContext;

@interface VideoManager () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMovieFileOutput *videoFileOutput;

@property (nonatomic, strong) AVCaptureDevice *frontCamera;
@property (nonatomic, strong) AVCaptureDevice *rearCamera;

@property (nonatomic) NSTimeInterval videoRecordingDuration;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) AVPlayerLayer *playaLaya;

@end

@implementation VideoManager

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        self.containerView = view;
        self.captureSession = [[AVCaptureSession alloc] init];
        [self.captureSession beginConfiguration];
        self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.previewLayer.frame = view.bounds;
        
        [view.layer addSublayer:self.previewLayer];
        
        AVCaptureDevice *device = self.frontCamera;
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (input) {
            [self.captureSession addInput:input];
        }

        error = nil;
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput * audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
        if (audioInput) {
            [self.captureSession addInput:audioInput];
        }
        
        // Create a new dated file
        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
        NSString *caldate = [now description];
        NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:caldate] stringByAppendingPathExtension:@"mp4"];

        self.videoRecorderFileURL = [NSURL fileURLWithPath:filePath];
        self.videoFileOutput = [[AVCaptureMovieFileOutput alloc] init];

        [self.captureSession addOutput:self.videoFileOutput];
        [self.captureSession commitConfiguration];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
    }
    
    return self;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceDidRotate:(NSNotification *)note {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self rotateVideoToOrientation:orientation];
}

- (void)stopVideoRecordingWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession stopRunning];
        [self.previewLayer removeFromSuperlayer];
        [self setupVideoPlaybackWithSuccess:^{
            NSLog(@"Video is ready");
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success();
                });
            }
        } failure:^{
            NSLog(@"Could not prep video");
        }];
    });
    
}

- (void)setupForVideoRecording {
    [self.playaLaya removeFromSuperlayer];
    
    [self.containerView.layer addSublayer:self.previewLayer];
    
    [self.captureSession removeOutput:self.videoFileOutput];

    
    // Create a new dated file
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:caldate] stringByAppendingPathExtension:@"mp4"];
    self.videoRecorderFileURL = [NSURL fileURLWithPath:filePath];
    
    self.videoFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    [self.captureSession addOutput:self.videoFileOutput];
    
    [self.captureSession startRunning];
}

- (void)rotateVideoToOrientation:(UIInterfaceOrientation)orientation
{
    if (![self.videoFileOutput isRecording]) {
        if ([self.previewLayer.connection isVideoOrientationSupported]) {
            self.previewLayer.connection.videoOrientation = [self avOrientationFromInterfaceOrientation:orientation];
        }
        
        if (self.videoFileOutput && self.videoFileOutput.connections.count > 0) {
            AVCaptureConnection *videoConnection = [self.videoFileOutput connections][0];
            
            if ([videoConnection isVideoOrientationSupported]) {
                [videoConnection setVideoOrientation:[self avOrientationFromInterfaceOrientation:orientation]];
            }
        }
    }
}

- (AVCaptureDevice *)frontCamera
{
    if (!_frontCamera) {
        [self populateCaptureDevices];
    }
    
    return _frontCamera;
}

- (AVCaptureDevice *)rearCamera
{
    if (!_rearCamera) {
        [self populateCaptureDevices];
    }
    
    return _rearCamera;
}

- (void)populateCaptureDevices
{
    NSArray *devices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in devices) {
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

- (void)deleteAndReset {
    [self clearRecordedMedia];
    [self setupForVideoRecording];
}

- (void)changeCamera {
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
    
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:&error];
    if (audioInput) {
        [self.captureSession addInput:audioInput];
    }
    
    [self.captureSession commitConfiguration];
}

- (BOOL)recordVideoComment
{
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
}

- (void)cleanUpAfterPlayingVideo
{
    [self.playaLaya setPlayer:nil];
}

- (void)stopCaptureSession
{
    if (self.captureSession) {
        [self.captureSession stopRunning];
        self.captureSession = nil;
    }
}

- (AVCaptureVideoOrientation)avOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // set the videoOrientation based on the device orientation to
    // ensure the pic is right side up for all orientations
    AVCaptureVideoOrientation videoOrientation;
    switch (interfaceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            // Not clear why but the landscape orientations are reversed
            // if I use AVCaptureVideoOrientationLandscapeLeft here the pic ends up upside down
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            // Not clear why but the landscape orientations are reversed
            // if I use AVCaptureVideoOrientationLandscapeRight here the pic ends up upside down
            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    
    return videoOrientation;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    if (context == &ItemStatusContext) {
//        if ((self.videoPlayer.currentItem != nil) && ([self.videoPlayer.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
////            self.playButton.enabled = YES;
//        }
//        else {
//            
//        }
//        return;
//    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    return;
}

- (void)setupVideoPlaybackWithSuccess:(void(^)(void))success failure:(void(^)(void))failure {
    
    // If there is no videoRecorderFileURL we haven't recorded anything yet
    if (!self.videoRecorderFileURL) {
        if (failure) {
            failure();
        }
    }
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.videoRecorderFileURL options:nil];
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        
        NSError *error = nil;
        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
        if (status == AVKeyValueStatusLoaded) {
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
            AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
            self.playaLaya = [AVPlayerLayer playerLayerWithPlayer:player];
            self.playaLaya.player = player;
            self.playaLaya.frame = self.containerView.bounds;
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.playaLaya.player currentItem]];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.containerView.layer addSublayer:self.playaLaya]; 
                if (success) {
                    success();
                }
            });
        }
        
    }];
    
}

#pragma mark - Video Playback Controls

- (void)playVideo {
    [self.playaLaya.player play];
}

- (void)pauseVideo {
    [self.playaLaya.player pause];
}

- (void)clearRecordedMedia {
    NSFileManager *manager = [NSFileManager new];

    if (self.videoRecorderFileURL) {
        [manager removeItemAtURL:self.videoRecorderFileURL error:NULL];
        self.videoRecordingDuration = 0.0;
        self.videoRecorderFileURL = nil;
    }
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex) {
        //Continue Anyway
    } else if (alertView.firstOtherButtonIndex == buttonIndex ){
        //Go To Settings
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else {
        //Don't Ask Again
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CSGUserPrefsIgnorePermissionsRequest];
    }
}

#pragma mark - Player Playback Callbacks

//Rewind to beginning
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate Methods

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    //I guess you could do something here if you cared
}

@end
