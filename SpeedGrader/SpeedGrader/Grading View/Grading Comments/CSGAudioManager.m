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

#import "CSGAudioManager.h"
#import "CSGUserPrefsKeys.h"

@interface CSGAudioManager ()

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, copy) UpdateTimeBlock updateTimeBlock;
@property (nonatomic, copy) FinishedPlaybackBlock finishedPlaybackBlock;

@property (nonatomic, copy) UpdateTimeBlock updateRecordingTimeBlock;
@property (nonatomic, copy) FinishedPlaybackBlock finishedRecordBlock;

@end

@implementation CSGAudioManager

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        [self setupAudioRecording];
    }
    
    return self;
}

- (void)setupAudioRecording
{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    
    self.audioRecorderFileURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:caldate] stringByAppendingPathExtension:@"wav"]];
    
    NSDictionary* recorderSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                      [NSNumber numberWithInt:22050.0f],AVSampleRateKey,
                                      [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                                      [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                      [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                      [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                      nil];
    
    NSError* error = nil;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.audioRecorderFileURL settings:recorderSettings error:&error];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    self.recorder.delegate = self;
}

#pragma mark - recording

- (void)stopAudioRecording
{
    if (self.recorder) {
        [self.recorder stop];
    }
}

- (BOOL)recordAudioComment
{
    if (self.recorder && [self.recorder prepareToRecord] == YES) {
        return [self.recorder record];
    }
    
    return NO;
}

- (BOOL)recordAudioCommentWithUpdateTimeBlock:(UpdateTimeBlock)updateBlock finishedBlock:(FinishedPlaybackBlock)finishedRecordBlock
{
    self.updateRecordingTimeBlock = updateBlock;
    self.finishedRecordBlock = finishedRecordBlock;
    BOOL success = [self recordAudioComment];
    
    if (self.updateRecordingTimeBlock) {
        [self clearTimerIfExists];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(updateRecordingTime)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    
    return success;
}

- (BOOL)deleteAudioRecording
{
    if (self.recorder) {
        [self resetTimer];
        if (self.recorder.isRecording) {
            [self.recorder stop];
        }
        
        if (self.player.duration) {
            return [self.recorder deleteRecording];
        } else {
            return YES;
        }
        
    }
    return NO;
}

#pragma mark - playback

- (void)setupAudioPlaybackWithSuccess:(void (^)())success Failure:(void (^)())failure
{
    if (!self.audioRecorderFileURL || !self.recorder) {
        failure();
        return;
    }
    
    NSError* error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:&error];
    if (!self.player) {
        NSLog(@"Error: %@", error);
        failure();
    }
    
    self.player.volume = 1.0f;
    self.player.numberOfLoops = 0;
    self.player.delegate = self;
    [self.player setVolume:1.f];
    success();
}

- (void)play
{
    if (self.player) {
        [self.player play];
    }
}

- (void)playWithUpdateTimeBlock:(UpdateTimeBlock)updateBlock finishedBlock:(FinishedPlaybackBlock)finishedPlaybackBlock
{
    self.updateTimeBlock = updateBlock;
    self.finishedPlaybackBlock = finishedPlaybackBlock;
    [self play];
    
    if (self.updateTimeBlock) {
        [self clearTimerIfExists];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(updateTimeLeft)
                                       userInfo:nil
                                        repeats:YES];
    }
}

#pragma mark - helper methods

- (void)updateRecordingTime {
    if (self.updateRecordingTimeBlock) {
        self.updateRecordingTimeBlock(self.recorder.currentTime);
    }
}

- (void)updateTimeLeft {
    if (self.updateTimeBlock) {
        self.updateTimeBlock(self.player.currentTime);
    }
}

- (void)pause
{
    if (self.player.isPlaying) {
        [self.player pause];
    }
}

- (void)clearTimerIfExists
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)resetTimer
{
    [self clearTimerIfExists];
    
    if (self.updateTimeBlock) {
        self.updateTimeBlock(0.0);
        self.updateTimeBlock = nil;
    }
}

#pragma mark - AVAudioPlayerDelegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self resetTimer];
    
    if (self.finishedPlaybackBlock) {
        self.finishedPlaybackBlock();
    }
}

#pragma mark - AVAudioRecorderDelegate Methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [self resetTimer];
    
    if (self.finishedRecordBlock) {
        self.finishedRecordBlock();
    }
}

#pragma mark - Helper Methods

- (NSInteger)totalAudioTimeInSeconds
{
    if (self.player) {
        return self.player.duration;
    }
    return 0;
}

@end
