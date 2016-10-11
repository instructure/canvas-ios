//
//  CSGVideoPlayerView.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 1/23/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import "CSGVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>

#import "CSGVideoSlider.h"

//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notifications
//////////////////////////////////////////////////////////////////////////////////////////////////
NSString *const CSGVideoPlayerViewReadyForDisplayNotification = @"CSGVideoPlayerViewReadyForDisplayNotification";
NSString *const CSGVideoPlayerViewFailedLoadAssetNotification = @"CSGVideoPlayerViewFailedLoadAssetNotification";
NSString *const CSGVideoPlayerViewAssetNotPlayableNotification = @"CSGVideoPlayerViewAssetNotPlayableNotification";
NSString *const CSGVideoPlayerViewAssetIsVideoNotification = @"CSGVideoPlayerViewAssetIsVideoNotification";
NSString *const CSGVideoPlayerViewAssetIsNotVideoNotification = @"CSGVideoPlayerViewAssetIsNotVideoNotification";

NSString *const CSGVideoPlayerViewAssetNotPlayableErrorKey = @"CSGVideoPlayerViewAssetIsNotVideoNotification";
NSString *const CSGVideoPlayerViewAssetFailedLoadAssetErrorKey = @"CSGVideoPlayerViewAssetFailedLoadAssetErrorKey";

//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants
//////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat const CSGVideoPlayerViewAutoHideControlsDelay = 4.0f;
CGFloat const CSGVideoPlayerViewAutoHideControlsAnimationDuration = 0.25f;


//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - KVO Contexts
//////////////////////////////////////////////////////////////////////////////////////////////////
static void *CSGVideoPlayerViewPlayerRateObservationContext = &CSGVideoPlayerViewPlayerRateObservationContext;
static void *CSGVideoPlayerViewPlayerCurrentItemObservationContext = &CSGVideoPlayerViewPlayerCurrentItemObservationContext;
static void *CSGVideoPlayerViewPlayerAirPlayVideoActiveObservationContext = &CSGVideoPlayerViewPlayerAirPlayVideoActiveObservationContext;
static void *CSGVideoPlayerViewPlayerItemStatusObservationContext = &CSGVideoPlayerViewPlayerItemStatusObservationContext;
static void *CSGVideoPlayerViewPlayerItemDurationObservationContext = &CSGVideoPlayerViewPlayerItemDurationObservationContext;
static void *CSGVideoPlayerViewPlayerLayerReadyForDisplayObservationContext = &CSGVideoPlayerViewPlayerLayerReadyForDisplayObservationContext;

@interface CSGVideoPlayerView () <UIGestureRecognizerDelegate>


@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

@property (nonatomic, strong, readwrite) AVAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, assign) CMTime duration;

@property (nonatomic, strong) id playerTimeObserver;

@property (nonatomic) BOOL seekToZeroBeforePlay;
@property (nonatomic) BOOL readyForDisplayTriggered;

// Controls
@property (nonatomic, strong) NSArray *controls;
@property (nonatomic, weak) IBOutlet UIView *controlContainerView;
@property (nonatomic, weak) IBOutlet UILabel *currentPlayerTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *remainingPlayerTimeLabel;
@property (nonatomic, weak) IBOutlet CSGVideoSlider *scrubberControlSlider;
@property (nonatomic, weak) IBOutlet UIButton *playPauseControlButton;
@property (nonatomic, weak) IBOutlet UIButton *initialPlayButton;

@property (nonatomic, strong) NSTimer *autoHideControlsTimer;

// Gesture Recognizers
@property (nonatomic, strong) UITapGestureRecognizer *singleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapRecognizer;

// Scrubbing
@property (nonatomic, getter = isScrubbing) BOOL scrubbing;
@property (nonatomic) float ratePriorToScrub;

@end

@implementation CSGVideoPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

+ (instancetype)instantiateFromXib {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil];
    CSGVideoPlayerView *instance = (CSGVideoPlayerView *)[nibViews objectAtIndex:0];
    NSAssert([instance isKindOfClass:[self class]], @"View from nib is not an instance of %@", NSStringFromClass(self));
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSError *error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupViews];
}

- (void)setupViews {
    [self.playerLayer setOpacity:0];
    [self.playerLayer addObserver:self
                       forKeyPath:@"readyForDisplay"
                          options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                          context:CSGVideoPlayerViewPlayerLayerReadyForDisplayObservationContext];
    
    [self addGestureRecognizer:self.singleTapRecognizer];
    [self addGestureRecognizer:self.doubleTapRecognizer];
    
    [self setRatePriorToScrub:0.0f];
    
    // Add controls
    self.controls = @[self.controlContainerView];
    [self.controls enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (!view.superview) {
            [self addSubview:view];
        }
    }];
    
    [self setControlsVisible:NO];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == CSGVideoPlayerViewPlayerItemStatusObservationContext) {
        [self syncPlayPauseButton];
        
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown: {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                [self setControlsEnabled:NO];
            }
                break;
            case AVPlayerStatusReadyToPlay: {
                [self setControlsEnabled:YES];
            }
                break;
            case AVPlayerStatusFailed: {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                [self setControlsEnabled:NO];
            }
                break;
        }
    } else if (context == CSGVideoPlayerViewPlayerRateObservationContext) {
        [self syncPlayPauseButton];
    } else if (context == CSGVideoPlayerViewPlayerCurrentItemObservationContext) {
        AVPlayerItem *newPlayerItem = change[NSKeyValueChangeNewKey];
        
        if ([newPlayerItem isEqual:[NSNull null]]) {
            [self removePlayerTimeObserver];
        } else {
            [self syncPlayPauseButton];
            [self addPlayerTimeObserver];
        }
    } else if (context == CSGVideoPlayerViewPlayerItemDurationObservationContext) {
        [self syncScrubber];
    } else if (context == CSGVideoPlayerViewPlayerLayerReadyForDisplayObservationContext) {
        BOOL ready = [change[NSKeyValueChangeNewKey] boolValue];
        if (ready && !self.readyForDisplayTriggered) {
            self.readyForDisplayTriggered = YES;
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [animation setFromValue:@0.0f];
            [animation setToValue:@1.0f];
            [animation setDuration:1.0];
            [self.playerLayer addAnimation:animation forKey:nil];
            [self.playerLayer setOpacity:1.0];
            
            self.initialPlayButton.hidden = NO;
            [self setControlsVisible:YES animated:YES];
        }
    } else if (context == CSGVideoPlayerViewPlayerAirPlayVideoActiveObservationContext) {
        // Show/hide airplay-image
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    [self removePlayerTimeObserver];
    
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"duration"];
    [self.playerLayer removeObserver:self forKeyPath:@"readyForDisplay"];
    
    [self.player pause];
}

#pragma mark - Properties

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    if (self.player) {
        [self removePlayerObservations:self.player];
    }
    
    [(AVPlayerLayer *) [self layer] setPlayer:player];
    
    [self addPlayerObservations:self.player];
}

- (void)removePlayerObservations:(AVPlayer *)player {
    [player removeObserver:self forKeyPath:@"rate"];
    [player removeObserver:self forKeyPath:@"currentItem"];
    if ([player respondsToSelector:@selector(allowsAirPlayVideo)]) {
        [player removeObserver:self forKeyPath:@"airPlayVideoActive"];
    }
}

- (void)addPlayerObservations:(AVPlayer *)player {
    // Optimize for airplay if possible
    if ([player respondsToSelector:@selector(allowsAirPlayVideo)]) {
        [player setAllowsExternalPlayback:YES];
        [player setUsesExternalPlaybackWhileExternalScreenIsActive:YES];
        
        [player addObserver:self
                 forKeyPath:@"airPlayVideoActive"
                    options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                    context:CSGVideoPlayerViewPlayerAirPlayVideoActiveObservationContext];
    }
    
    // Observe currentItem, catch the -replaceCurrentItemWithPlayerItem:
    [player addObserver:self
             forKeyPath:@"currentItem"
                options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                context:CSGVideoPlayerViewPlayerCurrentItemObservationContext];
    
    // Observe rate, play/pause-button?
    [player addObserver:self
             forKeyPath:@"rate"
                options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                context:CSGVideoPlayerViewPlayerRateObservationContext];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem) {
        [self removePlayerItemObservations:_playerItem];
    }
    
    _playerItem = playerItem;
    
    [self addPlayerItemObservations:_playerItem];
}

- (void)removePlayerItemObservations:(AVPlayerItem *)playerItem {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"duration"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.playerItem];
}

- (void)addPlayerItemObservations:(AVPlayerItem *)playerItem {
    // Observe status, ok -> play
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         context:CSGVideoPlayerViewPlayerItemStatusObservationContext];
    
    // Durationchange
    [self.playerItem addObserver:self
                      forKeyPath:@"duration"
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         context:CSGVideoPlayerViewPlayerItemDurationObservationContext];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           [self setControlsVisible:YES animated:YES];
                                                           [self setSeekToZeroBeforePlay:YES];
                                                       }];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)[self layer];
}

- (void)setUrl:(NSURL *)URL {
    if (self.playing) {
        [self.player pause];
    }
    
    _url = URL;
    
    // Create Asset, and load
    self.asset = [AVURLAsset URLAssetWithURL:URL options:nil];
    NSArray *keys = @[@"tracks", @"playable"];
    
    [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // Displatch to main queue!
            [self doneLoadingAsset:self.asset withKeys:keys];
        });
    }];
    
    [self setControlsVisible:YES animated:YES];
}

- (CMTime)duration {
    if ([self.playerItem respondsToSelector:@selector(duration)] && // 4.3
        self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        if (CMTIME_IS_VALID(self.playerItem.duration))
            return self.playerItem.duration;
    } else if (CMTIME_IS_VALID(self.player.currentItem.asset.duration)) {
        return self.player.currentItem.asset.duration;
    }
    
    return kCMTimeInvalid;
}

- (void)setControlsVisible:(BOOL)controlsVisible {
    [self setControlsVisible:controlsVisible animated:NO];
}

- (void)setPlaying:(BOOL)playing {
    if (playing) {
        if (self.seekToZeroBeforePlay)  {
            [self setSeekToZeroBeforePlay:NO];
            [self.player seekToTime:kCMTimeZero];
        }
        
        [self.player play];
        
        if (self.controlsVisible) {
            [self triggerAutoHideControlsTimer];
        }
    } else {
        [self.player pause];
        
        if (self.controlsVisible) {
            [self cancelAutoHideControlsTimer];
        }
    }
}

- (BOOL)playing {
    return (self.player.rate > 0.0f);
}

#pragma mark - Lazy Load Gesture Recognizers

- (UITapGestureRecognizer *)singleTapRecognizer {
    if (!_singleTapRecognizer) {
        _singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControlsWithRecognizer:)];
        [_singleTapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
        [_singleTapRecognizer setDelegate:self];
    }
    
    return _singleTapRecognizer;
}

- (UITapGestureRecognizer *)doubleTapRecognizer {
    if (!_doubleTapRecognizer) {
        _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleVideoGravityWithRecognizer:)];
        [_doubleTapRecognizer setNumberOfTapsRequired:2];
        [_doubleTapRecognizer setDelegate:self];
    }
    
    return _doubleTapRecognizer;
}

#pragma mark - Public

- (void)setControlsVisible:(BOOL)controlsVisible animated:(BOOL)animated {
    [self willChangeValueForKey:@"controlsVisible"];
    _controlsVisible = controlsVisible;
    [self didChangeValueForKey:@"controlsVisible"];
    
    if (controlsVisible) {
        [self setAllControlsHidden:NO];
    }
    
    [UIView animateWithDuration:(animated ? CSGVideoPlayerViewAutoHideControlsAnimationDuration : 0.0f)
                          delay:0.0f
                        options:(UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         [self.controls enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                             view.alpha = controlsVisible ? 1.0f : 0.0f;
                         }];
                     } completion:^(BOOL finished) {
                         if (!controlsVisible) {
                             [self setAllControlsHidden:YES];
                         }
                     }];
}

- (void)setAllControlsHidden:(BOOL)hidden {
    [self.controls enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view setHidden:hidden];
    }];
}

#pragma mark - Private

- (void)autoHideControlsTimerFire:(NSTimer *)timer {
    [self setControlsVisible:NO animated:YES];
    [self setAutoHideControlsTimer:nil];
}

- (void)triggerAutoHideControlsTimer {
    [self setAutoHideControlsTimer:[NSTimer scheduledTimerWithTimeInterval:CSGVideoPlayerViewAutoHideControlsDelay
                                                                    target:self
                                                                  selector:@selector(autoHideControlsTimerFire:)
                                                                  userInfo:nil
                                                                   repeats:NO]];
}

- (void)cancelAutoHideControlsTimer {
    [self.autoHideControlsTimer invalidate];
    [self setAutoHideControlsTimer:nil];
}

- (void)toggleControlsWithRecognizer:(UIGestureRecognizer *)recognizer {
    [self setControlsVisible:(!self.controlsVisible) animated:YES];
    
    if (self.controlsVisible && self.playing) {
        [self triggerAutoHideControlsTimer];
    }
}

- (void)toggleVideoGravityWithRecognizer:(UIGestureRecognizer *)recognizer {
    if (self.playerLayer.videoGravity == AVLayerVideoGravityResizeAspect) {
        [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    } else {
        [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    }
    
    [self.playerLayer setFrame:self.playerLayer.frame];
}

- (void)doneLoadingAsset:(AVAsset *)asset withKeys:(NSArray *)keys {
    // Check if all keys are OK
    for (NSString *key in keys) {
        NSError *error = nil;
        AVKeyValueStatus status = [asset statusOfValueForKey:key error:&error];
        if (status == AVKeyValueStatusFailed || status == AVKeyValueStatusCancelled) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CSGVideoPlayerViewFailedLoadAssetNotification object:self userInfo:@{CSGVideoPlayerViewAssetFailedLoadAssetErrorKey : error}];
            return;
        }
    }
    
    if (!asset.playable) {
        // Error
        [[NSNotificationCenter defaultCenter] postNotificationName:CSGVideoPlayerViewAssetNotPlayableNotification object:self];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CSGVideoPlayerViewReadyForDisplayNotification object:self];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    
    // Create the player
    if (!self.player) {
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    }
    
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self syncPlayPauseButton];
    
    // Scrub to start
    [self setSeekToZeroBeforePlay:YES];
    
    NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    if (![videoTracks count]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CSGVideoPlayerViewAssetIsNotVideoNotification object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:CSGVideoPlayerViewAssetIsVideoNotification object:self];
    }
}

- (void)addPlayerTimeObserver {
    if (!_playerTimeObserver) {
        __unsafe_unretained CSGVideoPlayerView *weakSelf = self;
        id observer = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(.5, NSEC_PER_SEC)
                                                                queue:dispatch_get_main_queue()
                                                           usingBlock:^(CMTime time) {
                                                               CSGVideoPlayerView *strongSelf = weakSelf;
                                                               if (CMTIME_IS_VALID(strongSelf.player.currentTime) && CMTIME_IS_VALID(strongSelf.duration)) {
                                                                   [strongSelf syncScrubber];
                                                               }
                                                           }];
        self.playerTimeObserver = observer;
    }
}

- (void)removePlayerTimeObserver {
    if (_playerTimeObserver) {
        [self.player removeTimeObserver:self.playerTimeObserver];
        self.playerTimeObserver = nil;
    }
}

- (IBAction)playPause:(id)sender {
    [self setPlaying:!self.playing];
}

- (void)syncPlayPauseButton {
    UIImage *playImage = [[UIImage imageNamed:@"icon_play_fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *pauseImage = [[UIImage imageNamed:@"icon_pause_fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.playPauseControlButton setImage:(self.playing ? pauseImage : playImage) forState:UIControlStateNormal];
}

- (IBAction)beginScrubbing:(id)sender {
    [self removePlayerTimeObserver];
    [self setScrubbing:YES];
    [self setRatePriorToScrub:self.player.rate];
    [self.player setRate:0.0f];
}

- (IBAction)scrub:(id)sender {
    // reset the auto hide timer
    [self cancelAutoHideControlsTimer];
    [self triggerAutoHideControlsTimer];
    [self syncTimeLabels];
    
    [self.player seekToTime:CMTimeMakeWithSeconds(self.scrubberControlSlider.value, NSEC_PER_SEC)];
}

- (IBAction)endScrubbing:(id)sender {
    [self.player setRate:self.ratePriorToScrub];
    [self setScrubbing:NO];
    [self addPlayerTimeObserver];
}

- (void)syncScrubber {
    NSInteger currentSeconds = ceilf(CMTimeGetSeconds(self.player.currentTime));
    NSInteger duration = ceilf(CMTimeGetSeconds(self.duration));
    
    self.scrubberControlSlider.minimumValue = 0.0f;
    self.scrubberControlSlider.maximumValue = duration;
    self.scrubberControlSlider.value = currentSeconds;
    
    [self syncTimeLabels];
}

- (void)syncTimeLabels {
    NSInteger currentSeconds = self.scrubberControlSlider.value;
    NSInteger seconds = currentSeconds % 60;
    NSInteger minutes = currentSeconds / 60;
    NSInteger hours = minutes / 60;
    
    NSInteger duration = ceilf(CMTimeGetSeconds(self.duration));
    NSInteger currentDurationSeconds = duration-currentSeconds;
    NSInteger durationSeconds = currentDurationSeconds % 60;
    NSInteger durationMinutes = currentDurationSeconds / 60;
    NSInteger durationHours = durationMinutes / 60;
    
    [self.currentPlayerTimeLabel setText:[NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds]];
    [self.remainingPlayerTimeLabel setText:[NSString stringWithFormat:@"-%02ld:%02ld:%02ld", (long)durationHours, (long)durationMinutes, (long)durationSeconds]];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // We dont want to to hide the controls when we tap em
    for (UIView *view in self.controls) {
        if (CGRectContainsPoint(view.frame, [touch locationInView:self]) && self.controlsVisible) {
            return NO;
        }
    }
    
    return YES;
}

- (void)setControlsEnabled:(BOOL)enabled {
    [self.controls enumerateObjectsUsingBlock:^(UIControl *control, NSUInteger idx, BOOL *stop) {
        control.enabled = enabled;
    }];
}

@end
