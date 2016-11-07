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

#import <UIKit/UIKit.h>

extern NSString *const CSGVideoPlayerViewReadyForDisplayNotification;
extern NSString *const CSGVideoPlayerViewFailedLoadAssetNotification;
extern NSString *const CSGVideoPlayerViewAssetNotPlayableNotification;
extern NSString *const CSGVideoPlayerViewAssetIsVideoNotification;
extern NSString *const CSGVideoPlayerViewAssetIsNotVideoNotification;

extern NSString *const CSGVideoPlayerViewAssetNotPlayableErrorKey;
extern NSString *const CSGVideoPlayerViewAssetFailedLoadAssetErrorKey;

@class AVPlayer;
@class AVAsset;

@interface CSGVideoPlayerView : UIView

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong, readonly) AVAsset *asset;

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) BOOL controlsVisible;

- (void)setControlsVisible:(BOOL)controlsVisible animated:(BOOL)animated;
+ (instancetype)instantiateFromXib;

@end
