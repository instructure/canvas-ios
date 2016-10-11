//
//  CSGAudioPlayerCell.h
//  SpeedGrader
//
//  Created by Nathan Lambson on 2/2/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSGAudioPlayer.h"

@class CSGAudioPlayerLarge;

typedef NS_ENUM(NSUInteger, CSGAudioPlaybackSpeed) {
    CSGAudioPlaybackHalf,
    CSGAudioPlaybackNormal,
    CSGAudioPlaybackOneAndHalf,
    CSGAudioPlaybackDouble,
    CSGNumberOfEntries
};

@interface CSGAudioPlayerLarge : CSGAudioPlayer

+ (id)presentInViewController:(UIViewController*)viewController;

- (void)setSpeed:(CSGAudioPlaybackSpeed)speed;
- (void)pause;


@property (nonatomic) CSGAudioPlaybackSpeed speed;
@property (weak, nonatomic) IBOutlet UIButton *fastForwardButton;
@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *playbackSpeedButton;
@end
