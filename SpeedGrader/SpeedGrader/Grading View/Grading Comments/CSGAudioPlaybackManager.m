//
//  CSGAudioPlaybackManager.m
//  SpeedGrader
//
//  Created by Ben Kraus on 1/13/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "CSGAudioPlaybackManager.h"
#import "CSGUserPrefsKeys.h"
#import "CSGAudioUtils.h"

//#import <Mantle/EXTScope.h>

#define FIFTEEN_SECONDS 15

NSString * const kAudioPlaybackManagerStatusKey = @"status";
NSString * const kAudioPlaybackManagerStatusContext = @"AVPlayerStatusContext";
NSString * const CSGAudioPlaybackStateKey = @"state";
NSString *CSGAudioPlaybackStateChangedForMedia(NSString *mediaID) {
    return [NSString stringWithFormat:@"%@_playback_changed", mediaID];
}

@interface CSGAudioPlaybackManager ()

@property (nonatomic, copy, readwrite) NSString *currentMediaID;
@property (nonatomic, strong, readwrite) AVPlayer *player;
@property (nonatomic, strong) id timeObserver;

@end

@implementation CSGAudioPlaybackManager

+ (instancetype)sharedManager
{
    static CSGAudioPlaybackManager *sharedAudioPlaybackManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAudioPlaybackManager = [[self alloc] init];
    });
    return sharedAudioPlaybackManager;
}

#pragma mark - Public methods

- (void)loadMedia:(NSString *)mediaID atURL:(NSURL *)url withTimeObserver:(void (^)(CMTime))timeObserver
{
    if ([self.currentMediaID isEqualToString:mediaID] && self.player.status == AVPlayerItemStatusReadyToPlay) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CSGAudioPlaybackStateChangedForMedia(self.currentMediaID) object:self userInfo:@{CSGAudioPlaybackStateKey:@(CSGAudioPlaybackManagerStateFinished)}];
        return;
    }

    if (self.player && [self isPlaying]) {
        [self pause];
    }

    if (self.player) { // for the case where the manager hasn't played anything yet
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        [self.player.currentItem removeObserver:self forKeyPath:kAudioPlaybackManagerStatusKey context:(__bridge void *) (kAudioPlaybackManagerStatusContext)];
        [self.player removeTimeObserver:self.timeObserver];
        [[NSNotificationCenter defaultCenter] postNotificationName:CSGAudioPlaybackStateChangedForMedia(self.currentMediaID) object:self userInfo:@{CSGAudioPlaybackStateKey:@(CSGAudioPlaybackManagerStateFinished)}]; // Inform the ui we are done with the old audio
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CSGAudioPlaybackStateChangedForMedia(mediaID) object:self userInfo:@{CSGAudioPlaybackStateKey:@(CSGAudioPlaybackManagerStateLoading)}];

    self.currentMediaID = mediaID;
    self.player = [AVPlayer playerWithURL:url];
    self.player.rate = 1.0f;
    self.timeObserverBlock = timeObserver;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self.player.currentItem addObserver:self forKeyPath:kAudioPlaybackManagerStatusKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:(__bridge void *)(kAudioPlaybackManagerStatusContext)];
    @weakify(self);
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 3) queue:NULL usingBlock:^(CMTime time) {
        @strongify(self);
        if (self.timeObserverBlock) {
            self.timeObserverBlock(time);
        }
    }];

    [self.player setMuted:NO];
    [self.player setVolume:1.f];
}

- (void)play
{
    if (self.player && self.player.status == AVPlayerItemStatusReadyToPlay) {
        [self.player.currentItem cancelPendingSeeks];
        [self.player play];
        [[NSNotificationCenter defaultCenter] postNotificationName:CSGAudioPlaybackStateChangedForMedia(self.currentMediaID) object:self userInfo:@{CSGAudioPlaybackStateKey:@(CSGAudioPlaybackManagerStatePlaying)}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:CSGAudioPlaybackStateChangedForMedia(self.currentMediaID) object:self userInfo:@{CSGAudioPlaybackStateKey:@(CSGAudioPlaybackManagerStateLoading)}];
    }
}

- (void)pause
{
    if (self.player) {
        [self.player.currentItem cancelPendingSeeks];
        [self.player pause];
        [[NSNotificationCenter defaultCenter] postNotificationName:CSGAudioPlaybackStateChangedForMedia(self.currentMediaID) object:self userInfo:@{CSGAudioPlaybackStateKey:@(CSGAudioPlaybackManagerStatePaused)}];
    }
}

- (void)seekToTime:(float)seekValue
{
    if (self.player && self.player.status == AVPlayerItemStatusReadyToPlay) {
        [self.player seekToTime:[CSGAudioUtils currentTimeForSliderWithPlayer:self.player SeekBarValue:seekValue] completionHandler:^(BOOL finished) {
            if (finished) {
                [self play];
                [[NSNotificationCenter defaultCenter] postNotificationName:CSGAudioPlaybackStateChangedForMedia(self.currentMediaID) object:self userInfo:@{CSGAudioPlaybackStateKey:@(CSGAudioPlaybackManagerStatePlaying)}];
            }
        }];
    }
}

- (void)stepBackward
{
    if (self.player && self.player.status == AVPlayerItemStatusReadyToPlay) {
        CMTime currentTime = self.player.currentTime;
        double timescale = currentTime.timescale;
        currentTime.value -= FIFTEEN_SECONDS * timescale;
        [self.player seekToTime:currentTime completionHandler:^(BOOL finished){
            [self play];
            if (self.timeObserverBlock) {
                self.timeObserverBlock(currentTime);
            }
        }];
    }
}

- (void)stepForward
{
    if (self.player && self.player.status == AVPlayerItemStatusReadyToPlay) {
        CMTime currentTime = self.player.currentTime;
        double timescale = currentTime.timescale;
        currentTime.value += FIFTEEN_SECONDS * timescale;
        [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
            [self play];
            if (self.timeObserverBlock) {
                self.timeObserverBlock(currentTime);
            }
        }];
    }
}

- (BOOL)isPlaying
{
    return (self.player.rate > 0 && !self.player.error);
}

#pragma mark - Notifications / Observers

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)(kAudioPlaybackManagerStatusContext)) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusFailed:
                [[NSNotificationCenter defaultCenter] postNotificationName:CSGAudioPlaybackStateChangedForMedia(self.currentMediaID) object:self userInfo:@{CSGAudioPlaybackStateKey:@(CSGAudioPlaybackManagerStateFailed)}];
                break;
            case AVPlayerStatusUnknown:
                break;
            case AVPlayerStatusReadyToPlay:
                [self play];
                [[NSNotificationCenter defaultCenter] postNotificationName:CSGAudioPlaybackStateChangedForMedia(self.currentMediaID) object:self userInfo:@{CSGAudioPlaybackStateKey:@(CSGAudioPlaybackManagerStatePlaying)}];
                break;
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self pause];
    [self.player seekToTime:kCMTimeZero];
    [[NSNotificationCenter defaultCenter] postNotificationName:CSGAudioPlaybackStateChangedForMedia(self.currentMediaID) object:self userInfo:@{CSGAudioPlaybackStateKey:@(CSGAudioPlaybackManagerStateFinished)}];
}

@end
