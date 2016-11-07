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
