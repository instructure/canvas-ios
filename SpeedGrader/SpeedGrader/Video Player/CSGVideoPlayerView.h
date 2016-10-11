//
//  CSGVideoPlayerView.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 1/23/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
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
