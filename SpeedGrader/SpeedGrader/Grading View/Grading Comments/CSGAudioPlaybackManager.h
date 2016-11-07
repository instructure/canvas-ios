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
