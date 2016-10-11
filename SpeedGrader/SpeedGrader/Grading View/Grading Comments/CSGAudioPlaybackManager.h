//
//  CSGAudioPlaybackManager.h
//  SpeedGrader
//
//  Created by Ben Kraus on 1/13/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVPlayer;

typedef NS_ENUM(NSInteger, CSGAudioPlaybackManagerState) {
    CSGAudioPlaybackManagerStateLoading,
    CSGAudioPlaybackManagerStatePaused,
    CSGAudioPlaybackManagerStatePlaying,
    CSGAudioPlaybackManagerStateFinished,
    CSGAudioPlaybackManagerStateFailed
};

extern NSString *const CSGAudioPlaybackStateKey;
NSString *CSGAudioPlaybackStateChangedForMedia(NSString *);

@interface CSGAudioPlaybackManager : NSObject

@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, copy, readonly) NSString *currentMediaID;

@property (nonatomic, copy) void (^timeObserverBlock)(CMTime);

+ (instancetype)sharedManager;

// Stops playback of any existing audio, and creates a new instance of the player, ready to play
- (void)loadMedia:(NSString *)mediaID atURL:(NSURL *)url withTimeObserver:(void (^)(CMTime))timeObserver;

- (void)play;
- (void)pause;
- (void)seekToTime:(float)time;
- (void)stepBackward;
- (void)stepForward;
- (BOOL)isPlaying;

@end
