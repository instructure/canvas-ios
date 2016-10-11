//
//  VideoRecorderView.m
//  SpeedGrader
//
//  Created by Rick Roberts on 11/13/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "VideoRecorderView.h"
#import "VideoManager.h"
#import <AVFoundation/AVFoundation.h>

typedef enum  {
    VideoRecorderViewStateDefault = 5000,
    VideoRecorderViewStateRecord,
    VideoRecorderViewStatePlay
} VideoRecorderViewState;

@interface VideoRecorderView () <UIAlertViewDelegate>
@property (nonatomic, strong) VideoManager *videoManager;
@property (nonatomic, assign) int timeSec;
@property (nonatomic, assign) int timeMin;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeCameraButton;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *trashButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (nonatomic, strong) UIAlertView *permissionsView;
@property (nonatomic) VideoRecorderViewState state;

@end

@implementation VideoRecorderView

- (void)awakeFromNib {

    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self.trashButton setImage:[[UIImage imageNamed:@"delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.trashButton.tintColor = [UIColor whiteColor];
    
    [self.changeCameraButton setImage:[[UIImage imageNamed:@"reverse"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.changeCameraButton.tintColor = [UIColor whiteColor];
    
    [self.postButton setImage:[[UIImage imageNamed:@"use"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.postButton.tintColor = [UIColor whiteColor];
    
    self.trashButton.hidden = YES;
    self.postButton.hidden = YES;
    
    self.videoManager = [[VideoManager alloc] initWithView:self.previewView];
    
    self.state = VideoRecorderViewStateDefault;
    
    self.permissionsView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Needs permissions", @"permissions alert view title")
                                                      message:NSLocalizedString(@"Camera and/or Microphone permissions are required", @"Camera and Microphone permissions alert view message")
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:nil];
    
    [self.permissionsView addButtonWithTitle:NSLocalizedString(@"Dismiss", @"permissions alert view cancel button")];
    [self.permissionsView addButtonWithTitle:NSLocalizedString(@"Go to Settings", @"permissions alert view ok button")];
    self.permissionsView.cancelButtonIndex = 0;
}

- (void)layoutSubviews {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.videoManager.previewLayer.frame = CGRectMake(0, 0, 300, 400);
    } else {
        self.videoManager.previewLayer.frame = CGRectMake(0, 0, 300, 225);
    }
    
    [self.videoManager rotateVideoToOrientation:orientation];
}

- (IBAction)toggleCamera:(id)sender {
    [self.videoManager changeCamera];
}

- (IBAction)trashButtonTouched:(id)sender {
    [self.videoManager deleteAndReset];
    [self updateViewForState:VideoRecorderViewStateDefault];
    
    if ([self.delegate respondsToSelector:@selector(videoDeletedRecording)]) {
        [self.delegate videoDeletedRecording];
    }
}

- (IBAction)postButtonTouched:(id)sender {
    
    [self.delegate postVideo:self.videoManager.videoRecorderFileURL];
}

- (BOOL) hasVideoPermissions
{
    NSString *mediaType = AVMediaTypeVideo;
    __block BOOL hasPermissions = NO;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        return YES;
    } else if(authStatus == AVAuthorizationStatusDenied){
        NSLog(@"There was an error attempting to use the audio capture device. Check Permissions.");
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
        NSLog(@"restricted, normally won't happen. Pay attention to this log statement if it does");
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access to %@", mediaType);
                hasPermissions = YES;
            } else {
                NSLog(@"Not granted access to %@", mediaType);
                hasPermissions = NO;
            }
        }];
    } else {
        // impossible, unknown authorization status
        NSLog(@"Unknown permissions check. This should not happen.");
    }
    
    return hasPermissions;
}

- (BOOL) hasAudioPermissions
{
    __block BOOL hasPermissions = NO;
    
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                hasPermissions = YES;
            } else {
                NSLog(@"There was an error attempting to use the audio capture device. Check Permissions.");
                hasPermissions = NO;
            }
        }];
    }
    
    return hasPermissions;
}

- (void)deleteVideo {
    [self.videoManager deleteAndReset];
}

- (IBAction)toggleRecord:(UIButton *)sender {
    switch (self.state) {
        case VideoRecorderViewStateDefault:
            
            if ([self hasAudioPermissions] && [self hasVideoPermissions]) {
                AudioServicesPlaySystemSound (1117);
                [self StartTimer];
                [self.videoManager recordVideoComment];
                [self updateViewForState:VideoRecorderViewStateRecord];
            } else {
                [self.permissionsView show];
            }
            break;
        case VideoRecorderViewStateRecord:
            AudioServicesPlaySystemSound (1118);
            [self.videoManager stopVideoRecordingWithSuccess:^{
                NSLog(@"Done");
            } failure:^(NSError *error) {
                NSLog(@"Fail");
            }];
            [self StopTimer];
            [self updateViewForState:VideoRecorderViewStatePlay];
            break;
        case VideoRecorderViewStatePlay:
            [self.videoManager playVideo];
            if ([self.delegate respondsToSelector:@selector(videoStartedRecording)]) {
                [self.delegate videoStartedRecording];
            }
            break;
        default:
            break;
    }
    
}

#pragma mark - State Management

- (void)updateViewForState:(VideoRecorderViewState)state {
    switch (state) {
        case VideoRecorderViewStateDefault:
            [self updateViewForDefaultState];
            self.state = state;
            break;
        case VideoRecorderViewStateRecord:
            [self updateViewForRecordingState];
            self.state = state;
            break;
        case VideoRecorderViewStatePlay:
            [self updateViewForPlayState];
            self.state = state;
            break;
        default:
            break;
    }
}

- (void)updateViewForDefaultState {
    self.trashButton.hidden = YES;
    self.postButton.hidden = YES;
    self.changeCameraButton.hidden = NO;
    
    [self.recordButton setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
}

- (void)updateViewForRecordingState {
    self.trashButton.hidden = YES;
    self.postButton.hidden = YES;
    self.changeCameraButton.hidden = YES;
    
    [self.recordButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
}

- (void)updateViewForPlayState {
    self.trashButton.hidden = NO;
    self.postButton.hidden = NO;
    self.changeCameraButton.hidden = YES;
    
    [self.recordButton setImage:[UIImage imageNamed:@"large_play_btn"] forState:UIControlStateNormal];
}


//Call This to Start timer, will tick every second
-(void) StartTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

//Event called every time the NSTimer ticks.
- (void)timerTick:(NSTimer *)timer
{
    self.timeSec++;
    if (self.timeSec == 60)
    {
        self.timeSec = 0;
        self.timeMin++;
    }
    //Format the string 00:00
    NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", self.timeMin, self.timeSec];
    //Display on your label
    //[timeLabel setStringValue:timeNow];
    self.timeLabel.text= timeNow;
}

//Call this to stop the timer event(could use as a 'Pause' or 'Reset')
- (void) StopTimer
{
    [self.timer invalidate];
    self.timeSec = 0;
    self.timeMin = 0;
    //Since we reset here, and timerTick won't update your label again, we need to refresh it again.
    //Format the string in 00:00
    NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", self.timeMin, self.timeSec];
    //Display on your label
    // [timeLabel setStringValue:timeNow];
    self.timeLabel.text= timeNow;
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex) {
        //Dismiss
    } else {
        //Go To Settings
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
