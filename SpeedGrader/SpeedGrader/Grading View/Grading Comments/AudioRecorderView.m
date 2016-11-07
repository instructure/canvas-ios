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

#import "AudioRecorderView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CSGAudioManager.h"


@interface AudioRecorderView () <UIAlertViewDelegate>
@property (nonatomic, strong) CSGAudioManager *audioManager;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic) NSInteger totalTime;

@property (nonatomic) CSGAudioRecordingState controlAction;

@property (nonatomic) BOOL playbackSetup;
@property (nonatomic) BOOL deletedRecording;
@property (nonatomic, strong) UIAlertView *permissionsView;

@end

@implementation AudioRecorderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.deletedRecording = NO;
    self.playbackSetup = NO;
    self.backgroundColor = [UIColor csg_gradingRailDefaultBackgroundColor];
    
    [self setupPostButton];
    
    self.recordButton.backgroundColor = [UIColor clearColor];
    self.recordButton.layer.cornerRadius = 25;
    self.recordButton.tintColor = [UIColor csg_gradingCommentPostCommentButtonBackgroundColor];
    [self.recordButton setImage:[UIImage imageNamed:@"icon_audio_fill"] forState:UIControlStateNormal];
    self.controlAction = CSGAudioRecordingStart;

    self.clearButton.backgroundColor = [UIColor clearColor];
    self.clearButton.tintColor = [UIColor csg_gradingCommentTrashCommentButtonColor];
    [self.clearButton setImage:[UIImage imageNamed:@"icon_trash"] forState:UIControlStateNormal];
    [self.clearButton setEnabled:NO];
    
    [self.postButton setEnabled:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0.0), ^{
        self.audioManager = [[CSGAudioManager alloc] initWithView:self];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self bringSubviewToFront:self.recordButton];
            [self bringSubviewToFront:self.timeLabel];
        });
    });
    
    self.permissionsView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Needs permissions", @"permissions alert view title")
                                                      message:NSLocalizedString(@"Microphone permissions are required", @"Microphone permissions alert view message")
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:nil];
    
    [self.permissionsView addButtonWithTitle:NSLocalizedString(@"Dismiss", @"permissions alert view cancel button")];
    [self.permissionsView addButtonWithTitle:NSLocalizedString(@"Go to Settings", @"permissions alert view ok button")];
    self.permissionsView.cancelButtonIndex = 0;
}

- (IBAction)toggleRecordButton:(UIButton *)sender
{
    if (self.controlAction == CSGAudioRecordingStart) {
        if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
            [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    AudioServicesPlaySystemSound (1113);
                    [self audioStartedRecording];
                } else {
                    [self.permissionsView show];
                    NSLog(@"There was an error attempting to use the audio capture device. Check Permissions.");
                }
            }];
        }
    } else if (self.controlAction == CSGAudioRecordingStop) {
        AudioServicesPlaySystemSound (1114);
        [self audioFinishedRecording];
        
    } else if (self.controlAction == CSGAudioRecordingPlay) {
        if (self.playbackSetup == YES) {
            [self audioPlaybackRecording];
        } else {
            [self audioSetupPlayback];
        }
        
    } else if (self.controlAction == CSGAudioRecordingPause) {
        [self audioPauseRecording];
        
    }
}

- (IBAction)clearSubmission:(id)sender {
    [self audioDeleteRecording];
}

- (IBAction)postSubmission:(id)sender {
    [self audioFinishedRecording];
    [self.delegate postAudio:self.audioManager.audioRecorderFileURL];
}

#pragma mark - Timer Methods for Recording

- (void)clearTime
{
    self.timeLabel.text= @"00:00";
}

#pragma mark - AudioRecorderViewDelegate Methods

- (void)audioStartedRecording
{
    if (self.audioManager) {
        self.deletedRecording = NO;
        self.controlAction = CSGAudioRecordingStop;
        
        [self.audioManager recordAudioCommentWithUpdateTimeBlock:^(NSInteger currentTime) {
            self.totalTime = currentTime;
            self.timeLabel.text = [self stringFormatForSeconds:currentTime];
        } finishedBlock:^{
            self.totalTime = [self.audioManager totalAudioTimeInSeconds] > self.totalTime ? [self.audioManager totalAudioTimeInSeconds] : self.totalTime;
            
            self.timeLabel.text = [@"-" stringByAppendingString:[self stringFormatForSeconds:self.totalTime]];
        }];
        
        [self.recordButton setImage:[UIImage imageNamed:@"icon_stop_fill"]  forState:UIControlStateNormal];
        self.recordButton.tintColor = [UIColor csg_red];
        [self.clearButton setEnabled:YES];
        [self.postButton setEnabled:YES];
    }
}

- (void)audioFinishedRecording
{
    if (self.audioManager) {
        [self.audioManager stopAudioRecording];
        [self.recordButton setImage:[UIImage imageNamed:@"icon_play_fill"]  forState:UIControlStateNormal];
        self.recordButton.tintColor = [UIColor csg_gradingCommentPostCommentButtonBackgroundColor];
        self.controlAction = CSGAudioRecordingPlay;
        [self.clearButton setEnabled:YES];
        [self.postButton setEnabled:YES];
    }
}

- (void)audioDeleteRecording
{
    if (self.audioManager) {
        [self audioPauseRecording];
        [self audioFinishedRecording];
        
        self.deletedRecording = [self.audioManager deleteAudioRecording];
        self.playbackSetup = NO;
        self.controlAction = CSGAudioRecordingStart;
        
        [self.recordButton setImage:[UIImage imageNamed:@"icon_audio_fill"]  forState:UIControlStateNormal];
        [self.recordButton setTintColor:[UIColor csg_gradingCommentPostCommentButtonBackgroundColor]];
        
        [self.clearButton setEnabled:NO];
        [self.postButton setEnabled:NO];

        [self clearTime];
    }
}

- (void)audioSetupPlayback
{
    if (self.audioManager) {
        [self.audioManager setupAudioPlaybackWithSuccess:^{
            self.playbackSetup = YES;
            [self audioPlaybackRecording];
        } Failure:^{
            self.playbackSetup = NO;
            NSLog(@"Audio Player failed to find or load the audio recording");
        }];
    }
}

- (void)audioPlaybackRecording
{
    if (self.audioManager && self.deletedRecording == NO) {
        [self.audioManager playWithUpdateTimeBlock:^(NSInteger currentTime) {
            self.timeLabel.text = [@"-" stringByAppendingString:[self stringFormatForSeconds:[self.audioManager totalAudioTimeInSeconds] - currentTime]];
        } finishedBlock:^{
            if (self.deletedRecording) {
                [self clearTime];
            } else {
                [self audioPauseRecording];
            }
        }];
        
        [self.clearButton setEnabled:YES];
        [self.postButton setEnabled:YES];
        [self.recordButton setImage:[UIImage imageNamed:@"icon_pause_fill"]  forState:UIControlStateNormal];
        self.controlAction = CSGAudioRecordingPause;
    }
}

- (void)audioPauseRecording
{
    if (self.audioManager && self.deletedRecording == NO) {
        [self.audioManager pause];
        [self.clearButton setEnabled:YES];
        [self.postButton setEnabled:YES];
        [self.recordButton setImage:[UIImage imageNamed:@"icon_play_fill"]  forState:UIControlStateNormal];
        self.controlAction = CSGAudioRecordingPlay;
    }
}

#pragma mark - Helper methods

- (NSString *)stringFormatForSeconds:(NSInteger)seconds
{
    NSString *emptyString = @"00:00";
    
    if (seconds <= 0) {
        return emptyString;
    }
    
    if (seconds < 60) {
        return [NSString stringWithFormat:@"00:%02ld",(long)seconds];
    }
    
    if (seconds < 3600) {
        int minutes = floor(seconds/60);
        int rseconds = trunc(seconds - minutes * 60);
        
        return [NSString stringWithFormat:@"%02d:%02d",minutes,rseconds];
    }
    
    if (seconds >= 3600) {
        int hours = floor(seconds/60);
        int minutes = floor(seconds/60);
        int rseconds = trunc(seconds - minutes * 60);
        
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes,rseconds];
    }
    
    return emptyString;
}

- (void)setupPostButton
{
    self.postButton.backgroundColor = [UIColor csg_gradingCommentPostCommentButtonBackgroundColor];
    self.postButton.tintColor = [UIColor csg_gradingCommentPostCommentButtonTextColor];
    [self.postButton setTitle:NSLocalizedString(@"Post", @"Post Comment Button Text") forState:UIControlStateNormal];
    
    self.postButton.layer.cornerRadius = 3.0f;
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
