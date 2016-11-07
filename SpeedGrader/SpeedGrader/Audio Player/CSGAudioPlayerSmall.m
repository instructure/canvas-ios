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

#import "CSGAudioPlayerSmall.h"
#import <AVFoundation/AVFoundation.h>
#import "CSGUserPrefsKeys.h"
#import "CSGAudioPlaybackManager.h"
#import "CSGGradingCommentCell.h"
#import "CSGAudioUtils.h"

@import ReactiveCocoa;
@import Masonry;

@interface CSGAudioPlayerSmall ()
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic) BOOL isCell;
@end

@implementation CSGAudioPlayerSmall

+ (id)presentInTableViewCell:(CSGGradingCommentCell *)tableViewCell
{
    CSGAudioPlayerSmall *audioView = [[[NSBundle mainBundle] loadNibNamed:@"CSGAudioPlayerSmall" owner:tableViewCell options:nil] firstObject];
    [tableViewCell.mediaContainerView addSubview:audioView];

    audioView.isCell = YES;
    
    return audioView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    UIImage *thumbIcon = [UIImage imageNamed:@"icon_audio_handle"];
    [self.seekBar setThumbImage:thumbIcon forState:UIControlStateNormal];
    [self.seekBar setThumbImage:thumbIcon forState:UIControlStateHighlighted];
    
    [self resetUI];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setMediaID:(NSString *)mediaID
{
    if (![self.mediaID isEqualToString:mediaID]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CSGAudioPlaybackStateChangedForMedia(self.mediaID) object:nil];
    }

    [super setMediaID:mediaID];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlaybackStateChanged:) name:CSGAudioPlaybackStateChangedForMedia(mediaID) object:nil];

    if ([[CSGAudioPlaybackManager sharedManager] currentMediaID] == mediaID && [[CSGAudioPlaybackManager sharedManager] isPlaying]) {
        [self setUIForState:CSGAudioPlaybackManagerStatePlaying];
        [CSGAudioPlaybackManager sharedManager].timeObserverBlock = ^(CMTime time) {
            [self syncUI:time];
        };
    }
}

- (void)mediaPlaybackStateChanged:(NSNotification *)notification
{
    CSGAudioPlaybackManagerState state = [notification.userInfo[CSGAudioPlaybackStateKey] integerValue];
    [self setUIForState:state];
}

- (void)resetUI
{
    [self setUIForState:CSGAudioPlaybackManagerStatePaused];
    self.totalLabel.text = @"--:--"; // reset to initial, unloaded state
}

- (void)setUIForState:(CSGAudioPlaybackManagerState)state
{
    switch (state) {
        case CSGAudioPlaybackManagerStateLoading:
            [self.playButton setImage:[UIImage imageNamed:@"icon_play_fill"]  forState:UIControlStateNormal];
            self.loading.hidden = NO;
            [self.loading startAnimating];
            [self syncUI:kCMTimeZero];
            self.playButton.enabled = NO;
            self.seekBar.enabled = NO;
            self.remainingLabel.text = NSLocalizedString(@"Loading...", @"The title while the audio control is still loading");
            break;
        case CSGAudioPlaybackManagerStatePaused:
            [self.playButton setImage:[UIImage imageNamed:@"icon_play_fill"]  forState:UIControlStateNormal];
            [self.loading stopAnimating];
            self.loading.hidden = YES;
            [self syncUI:[CSGAudioPlaybackManager sharedManager].player.currentTime];
            self.playButton.enabled = YES;
            self.seekBar.enabled = YES;
            self.remainingLabel.text = [CSGAudioUtils titleForFileWithPlayer:[CSGAudioPlaybackManager sharedManager].player];
            break;
        case CSGAudioPlaybackManagerStatePlaying:
            [self.playButton setImage:[UIImage imageNamed:@"icon_pause_fill"] forState:UIControlStateNormal];
            [self.loading stopAnimating];
            self.loading.hidden = YES;
            self.playButton.enabled = YES;
            self.seekBar.enabled = YES;
            self.remainingLabel.text = [CSGAudioUtils titleForFileWithPlayer:[CSGAudioPlaybackManager sharedManager].player];
            break;
        case CSGAudioPlaybackManagerStateFinished:
            [self syncUI:kCMTimeZero];
            [self setUIForState:CSGAudioPlaybackManagerStatePaused];
            break;
        case CSGAudioPlaybackManagerStateFailed:
            [self.playButton setImage:[UIImage imageNamed:@"icon_play_fill"]  forState:UIControlStateNormal];
            [self.loading stopAnimating];
            self.loading.hidden = YES;
            [self syncUI:kCMTimeZero];
            self.playButton.enabled = NO;
            self.seekBar.enabled = NO;
            self.remainingLabel.text = NSLocalizedString(@"Sorry, the file failed to load.", @"Error message for AVPlayerStatusFailed");
            break;
        default: // shouldn't get here, every case explicitly handled
            break;
    }
}

- (void)syncUI:(CMTime)time
{
    if ([self.seekBar isTracking] || [self.seekBar isTouchInside] || !time.value) {
        return;
    }

    [self.seekBar setValue:[CSGAudioUtils currentPositionForTime:time Player:[CSGAudioPlaybackManager sharedManager].player] animated:YES];
    
    NSInteger remainingSeconds = [CSGAudioUtils totalAudioTimeInSecondsForPlayer:[CSGAudioPlaybackManager sharedManager].player] - CMTimeGetSeconds(time);
    self.totalLabel.text = [NSString stringWithFormat:@"-%@", [CSGAudioUtils stringFormatForSeconds:remainingSeconds]];
}

#pragma mark - Public

- (void)preloadMedia
{
    [[CSGAudioPlaybackManager sharedManager] loadMedia:self.mediaID atURL:self.audioURL withTimeObserver:^(CMTime time) {
        [self syncUI:time];
    }];
}

#pragma mark - actions

- (IBAction)togglePlayPause
{
    if ([[CSGAudioPlaybackManager sharedManager] isPlaying] && [[CSGAudioPlaybackManager sharedManager].currentMediaID isEqualToString:self.mediaID]) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)play
{
    [self preloadMedia];
}

- (void)pause
{
    [[CSGAudioPlaybackManager sharedManager] pause];
    [self setUIForState:CSGAudioPlaybackManagerStatePaused];
}

- (IBAction)seek:(UISlider *)slider
{
    [[CSGAudioPlaybackManager sharedManager] seekToTime:self.seekBar.value];
}

@end
