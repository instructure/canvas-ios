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

#import "CSGAudioPlayerLarge.h"
#import <AVFoundation/AVFoundation.h>
#import "CSGUserPrefsKeys.h"
#import "CSGAudioUtils.h"
@import Masonry;
#import "CSGAudioPlaybackManager.h"

#define FIFTEEN_SECONDS 15

NSString * const kAudioPlayerStatusKey = @"status";
NSString * const kAudioPlayerItemKey = @"currentItem";

static void *kAudioPlayerStatusContext = &kAudioPlayerStatusContext;
static void *kAudioPlayerItemContext = &kAudioPlayerItemContext;


@interface CSGAudioPlayerLarge ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, weak) IBOutlet UIView *loadingBG;
@property (nonatomic, weak) IBOutlet UILabel *elapsedLabel;
@end

@implementation CSGAudioPlayerLarge

+ (id)presentInViewController:(UIViewController *)viewController
{
    CSGAudioPlayerLarge *audioView = [[[NSBundle mainBundle] loadNibNamed:@"CSGAudioPlayerLarge" owner:viewController options:nil] firstObject];
    
    [viewController.view addSubview:audioView];
    
    //add constraints with Masonry
    [audioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewController.view.mas_centerX);
        make.centerY.equalTo(viewController.view.mas_centerY);
    }];
    
    audioView.speed = [[NSUserDefaults standardUserDefaults] integerForKey:CSGUserPrefsAudioPlaybackSpeed];
    
    return audioView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupAppearance];
}

- (void)setupAppearance
{
    [self resetAVPlayer];
    self.isPlaying = NO;
    [self layoutViews];
    [self syncUI:kCMTimeZero];
}

- (void)dealloc
{
    [self resetAVPlayer];
}

- (void) resetAVPlayer {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self.player removeObserver:self forKeyPath:kAudioPlayerStatusKey context:kAudioPlayerStatusContext];
    [self.player removeObserver:self forKeyPath:kAudioPlayerItemKey context:kAudioPlayerItemContext];
    [self.player removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.player = nil;
}

- (void)layoutViews
{
    UIImage *thumbIcon = [UIImage imageNamed:@"icon_audio_handle"];
    [self.seekBar setThumbImage:thumbIcon forState:UIControlStateNormal];
    [self.seekBar setThumbImage:thumbIcon forState:UIControlStateHighlighted];
    [self.playbackSpeedButton.layer setCornerRadius:10.f];
    if (self.tintColor == nil) {
        self.tintColor = self.playbackSpeedButton.tintColor;
    }
    [self.loading startAnimating];
}

- (void)syncSlider:(CMTime)time
{
    if ([self.seekBar isTracking] || [self.seekBar isTouchInside]) {
        return;
    }
    
    [self.seekBar setValue:[CSGAudioUtils currentPositionForTime:time Player:self.player] animated:YES];
}

- (void)syncUI:(CMTime)time
{
    if (time.value == 0) {
        time = [CSGAudioUtils currentTimeForSliderWithPlayer:self.player SeekBarValue:self.seekBar.value];
    }
    
    if ((self.player.currentItem != nil) && ([self.player status] == AVPlayerItemStatusReadyToPlay)) {
        self.playButton.enabled = YES;
        self.fastForwardButton.enabled = YES;
        self.rewindButton.enabled = YES;
        self.playbackSpeedButton.enabled = YES;
        self.seekBar.enabled = YES;
    } else {
        self.playButton.enabled = NO;
        self.fastForwardButton.enabled = NO;
        self.rewindButton.enabled = NO;
        self.playbackSpeedButton.enabled = NO;
        self.seekBar.enabled = NO;
    }
    
    NSInteger remainingSeconds = [CSGAudioUtils totalAudioTimeInSecondsForPlayer:self.player] - CMTimeGetSeconds(time);
    self.elapsedLabel.text = [CSGAudioUtils stringFormatForCMTime:time];
    self.totalLabel.text = [NSString stringWithFormat:@"-%@", [CSGAudioUtils stringFormatForSeconds:remainingSeconds]];
    if ([self.loading isAnimating]) {
        self.remainingLabel.text = NSLocalizedString(@"Loading ...", @"The Title while the Audio Control is still loading");
    } else {
        self.remainingLabel.text = [CSGAudioUtils titleForFileWithPlayer:self.player];
    }
}

#pragma mark - actions

- (void)preloadURL
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self resetAVPlayer];
        self.player = [AVPlayer playerWithURL:self.audioURL];
        //For debugging
        //NSLog(@"loading player %@ with audioURL: %@", self.player, self.audioURL.description);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        
        [self.player addObserver:self forKeyPath:kAudioPlayerItemKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:kAudioPlayerItemContext];
        [self.player addObserver:self forKeyPath:kAudioPlayerStatusKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:kAudioPlayerStatusContext];
        
        [self.player setMuted:NO];
        [self.player setVolume:1.f];
    });
}

- (IBAction)stepBackward
{
    if (self.player && self.player.status == AVPlayerItemStatusReadyToPlay) {
        
        CMTime currentTime = self.player.currentTime;
        double timescale = currentTime.timescale;
        currentTime.value -= FIFTEEN_SECONDS * timescale;
        [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
            [self syncSlider: currentTime];
            [self play];
        }];
    }
}

- (IBAction)stepForward
{
    if (self.player && self.player.status == AVPlayerItemStatusReadyToPlay) {
        
        CMTime currentTime = self.player.currentTime;
        double timescale = currentTime.timescale;
        currentTime.value += FIFTEEN_SECONDS * timescale;
        [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
            [self syncSlider: currentTime];
            [self play];
        }];
    }
}

- (void)play
{
    if (self.player) {
        if (self.timeObserver == nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                __weak id weakSelf = self;
                self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 3) queue:NULL usingBlock:^(CMTime time) {
                    [weakSelf syncSlider:time];
                    [weakSelf syncUI:time];
                }];
            });
        }
        
        [[CSGAudioPlaybackManager sharedManager] pause];
        [self.player.currentItem cancelPendingSeeks];
        [self.player play];
        [self syncPlaybackSpeed];
        self.isPlaying = YES;
        [self.playButton setImage:[UIImage imageNamed:@"icon_pause_fill"]  forState:UIControlStateNormal];
    }
}

- (void)pause
{
    if (self.player) {
        [self.player.currentItem cancelPendingSeeks];
        [self.player pause];
        self.isPlaying = NO;
        [self.playButton setImage:[UIImage imageNamed:@"icon_play_fill"]  forState:UIControlStateNormal];
    }
}

- (IBAction)togglePlayPause
{
    if (!self.player) {
        return;
    }
    
    if (self.isPlaying) {
        [self pause];
    } else {
        [self play];
    }
}

- (IBAction)seek:(UISlider *)slider
{
    if (!self.player || self.player.status != AVPlayerItemStatusReadyToPlay) {
        return;
    }
    
    [self.player seekToTime:[CSGAudioUtils currentTimeForSliderWithPlayer:self.player SeekBarValue:self.seekBar.value] completionHandler:^(BOOL finished) {
        if (!self.isPlaying) {
            [self play];
        }
    }];
}

- (IBAction)playbackSpeedButtonPressed
{
    self.speed += 1;
    if (!self.isPlaying) {
         [self play];
    }
}

- (CSGAudioPlaybackSpeed)speedForPlaybackRate:(CGFloat)rate
{
    if (rate == .5) {
        return CSGAudioPlaybackHalf;
    } else if (rate == 1.5) {
        return CSGAudioPlaybackOneAndHalf;
    } else if (rate == 2) {
        return CSGAudioPlaybackDouble;
    }
    
    return CSGAudioPlaybackNormal;
}

- (void)syncPlaybackSpeed
{
    if (self.speed == CSGNumberOfEntries) {
        self.speed = CSGAudioPlaybackHalf;
    }
    
    [self invertPlaybackSpeedButtonColors];
    
    switch (self.speed) {
        case CSGAudioPlaybackHalf:
            if ([self.player.currentItem canPlaySlowForward]) {
                self.player.rate = 0.5f;
                [self.playbackSpeedButton setTitle:NSLocalizedString(@"Speed 0.5x", @"Title for playback speed button at .5x") forState:UIControlStateNormal];
                break;
            }
        case CSGAudioPlaybackOneAndHalf:
            if ([self.player.currentItem canPlayFastForward]) {
                self.player.rate = 1.5f;
                [self.playbackSpeedButton setTitle:NSLocalizedString(@"Speed 1.5x", @"Title for playback speed button at 1.5x") forState:UIControlStateNormal];
                break;
            }
        case CSGAudioPlaybackDouble:
            if ([self.player.currentItem canPlayFastForward]) {
                self.player.rate = 2.0f;
                [self.playbackSpeedButton setTitle:NSLocalizedString(@"Speed 2x", @"Title for playback speed button at 2x") forState:UIControlStateNormal];
                break;
            }
        default:
            self.player.rate = 1.0f;
            [self.playbackSpeedButton setTitle:NSLocalizedString(@"Speed 1x", @"Title for playback speed button at 1x") forState:UIControlStateNormal];
            [self.playbackSpeedButton setBackgroundColor:[UIColor whiteColor]];
            [self.playbackSpeedButton setTitleColor:self.tintColor forState:UIControlStateNormal];
            break;
    }
}

- (void)setSpeed:(CSGAudioPlaybackSpeed)speed
{
    _speed = speed;
    [[NSUserDefaults standardUserDefaults] setInteger:self.speed forKey:CSGUserPrefsAudioPlaybackSpeed];
    [self syncPlaybackSpeed];
}

- (void)invertPlaybackSpeedButtonColors
{
    [self.playbackSpeedButton setBackgroundColor:self.tintColor];
    [self.playbackSpeedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - Getter / Setters

- (void)setAudioURL:(NSURL *)audioURL
{   
    if (audioURL) {
        [super setAudioURL:audioURL];
        [self preloadURL];
    }
}

//listen for notificatoin

#pragma mark - Notifications / Observers

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kAudioPlayerStatusContext && object == self.player && [path isEqualToString:kAudioPlayerStatusKey]) {
        switch (self.player.status) {
            case AVPlayerStatusFailed:
                [self.loading stopAnimating];
                self.loading.hidden = YES;
                [self syncUI:kCMTimeZero];
                self.remainingLabel.text = NSLocalizedString(@"Sorry, the file failed to load.", @"Error message for AVPlayerStatusFailed");
                break;
            case AVPlayerStatusUnknown:
                break;
            case AVPlayerStatusReadyToPlay:
                self.loadingBG.hidden = YES;
                [self.loading stopAnimating];
                self.loading.hidden = YES;
                [self syncUI:kCMTimeZero];
                self.speed = [[NSUserDefaults standardUserDefaults] integerForKey:CSGUserPrefsAudioPlaybackSpeed];
                [self syncPlaybackSpeed];
                [self pause];
                
                break;
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self pause];
    [self.player seekToTime:kCMTimeZero];
    [self.seekBar setValue:0 animated:YES];
}


@end
