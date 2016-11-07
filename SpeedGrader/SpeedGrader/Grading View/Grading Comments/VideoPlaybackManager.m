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

#import "VideoPlaybackManager.h"
#import <AVFoundation/AVFoundation.h>

/* Asset keys */
NSString * const kTracksKey = @"tracks";
NSString * const kPlayableKey = @"playable";

/* PlayerItem keys */
NSString * const kStatusKey         = @"status";
NSString * const kCurrentItemKey	= @"currentItem";

@interface VideoPlaybackManager ()
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@end

static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;

@implementation VideoPlaybackManager

- (void)setSourceURL:(NSURL *)sourceURL {
    _sourceURL = [sourceURL copy];
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:_sourceURL];
    NSArray *requestedKeys = @[kTracksKey, kPlayableKey];
    
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self prepareToPlayAsset:asset withKeys:requestedKeys];
        });
    }];
}

- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys {
    for (NSString *key in requestedKeys) {
        NSError *error = nil;
        
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
        if (keyStatus == AVKeyValueStatusFailed) {
            return;
        }
    }
    
    if (!asset.playable) {
        return;
    }
    
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    }
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    if (!self.player) {
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        [self.player addObserver:self forKeyPath:kCurrentItemKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
    }
    
    if (self.player.currentItem != self.playerItem) {
        [self.player  replaceCurrentItemWithPlayerItem:self.playerItem];
    }
}

- (void)observeValueForKeyPath: (NSString*) path ofObject: (id)object change: (NSDictionary*)change context: (void*)context {
    if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerStatusReadyToPlay) {
            [self.player play];
        }
    } else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext) {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (newPlayerItem) {
            [self.playerView setPlayer:self.player];
            [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
        }
    } else {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}

- (VideoPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[VideoPlayerView alloc] init];
    }
    return _playerView;
}

@end
