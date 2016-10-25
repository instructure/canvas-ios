//
//  PSPDFMediaPlayerController.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSPDFMediaPlayerControlStyle) {
    /// Shows no controls whatsoever.
    PSPDFMediaPlayerControlStyleNone,

    /// Shows the default control set.
    PSPDFMediaPlayerControlStyleDefault
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFMediaPlayerControllerContentState) {
    /// The player has no idea what the content state is and hasn't started.
    PSPDFMediaPlayerControllerContentStateIdle,

    /// The player is currently loading information about the content.
    PSPDFMediaPlayerControllerContentStateLoading,

    /// The player has found that the content is playable.
    PSPDFMediaPlayerControllerContentStateReady,

    /// The player has encountered an error. This might be because the Internet
    /// connection is unavailable to fetch a remote item or because the item is
    /// unsupported. You can query `contentError` to find out what exactly went wrong.
    PSPDFMediaPlayerControllerContentStateError
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFMediaPlayerCoverMode) {
    /// Shows a preview of the video as the cover.
    PSPDFMediaPlayerCoverModePreview,

    /// Shows a custom image as the cover.
    PSPDFMediaPlayerCoverModeCustom,

    /// Hides the cover completely.
    /// @note If you chose this cover mode, the underlaying player instance will be initialized even
    /// if the content is not playing yet.
    PSPDFMediaPlayerCoverModeHidden,

    /// Shows the cover and hides the video view while the cover is visible.
    PSPDFMediaPlayerCoverModeClear
} PSPDF_ENUM_AVAILABLE;

@protocol PSPDFMediaPlayerControllerDelegate;

/// A simply media player.
PSPDF_CLASS_AVAILABLE @interface PSPDFMediaPlayerController : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initialize the player controller with the URL of the media file.
- (instancetype)initWithContentURL:(NSURL *)contentURL NS_DESIGNATED_INITIALIZER;

/// The content URL of the item that the player plays.
@property (nonatomic, copy, readonly) NSURL *contentURL;

/// If an error occurred while preparing the content for playback, this will bet set.
@property (nonatomic, readonly, nullable) NSError *contentError;

/// Starts playing the media.
- (void)play;

/// Pauses the media.
- (void)pause;

/// Pauses all instances of this class.
+ (void)pauseAllInstances;

/// Seek to `time`.
- (void)seekToTime:(CMTime)time;

/// Indicates if the player did finish playing the entire video.
@property (nonatomic, readonly) BOOL didFinishPlaying;

/// If the media is currently playing, this returns YES.
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;

/// Indicates if the player uses external playback.
@property (nonatomic, readonly, getter=isExternalPlaybackActive) BOOL externalPlaybackActive;

/// The current state of the content.
@property (nonatomic, readonly) PSPDFMediaPlayerControllerContentState contentState;

/// The cover mode.
@property (nonatomic) PSPDFMediaPlayerCoverMode coverMode;

/// The URL of the cover image to be displayed. Only effective if `coverMode` is set to
/// `PSPDFMediaPlayerCoverModeCustom`.
@property (nonatomic, nullable) NSURL *coverImageURL;

/// The time in the video at which the image for the cover is captured. Only effective if `coverMode`
/// is set to `PSPDFMediaPlayerCoverModePreview`. Defaults to 2 seconds.
@property (nonatomic) CMTime coverImagePreviewCaptureTime;

/// The player's delegate.
@property (nonatomic, weak) IBOutlet id <PSPDFMediaPlayerControllerDelegate> delegate;

/// Set this to YES if you want to hide the toolbar. This property might be ignored
/// if it is set to NO in case the `PSPDFMediaPlayerCoverView` is visible. Use view.toolbar.hidden
/// to access the actual visibility state of the toolbar. Normally you don't need to change
/// this property yourself because `PSPDFMediaPlayerController` handles it for you.
/// Defaults to YES.
@property (nonatomic) BOOL shouldHideToolbar;
- (void)setShouldHideToolbar:(BOOL)shouldHideToolbar animated:(BOOL)animated;

/// Indicates that the player has started playing, although it might not be playing right now.
/// Defaults to NO.
@property (nonatomic, readonly) BOOL didStartPlaying;

/// The tap gesture recognizer used for toggling the toolbar.
@property (nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;

/// Enables playback looping. Defaults to `NO`.
@property (nonatomic) BOOL loopEnabled;

/// Uses external playback automatically while an external screen is active. Defaults to `YES`.
@property (nonatomic) BOOL usesExternalPlaybackWhileExternalScreenIsActive;

/// The control style of the media player. Defaults to `PSPDFMediaPlayerControlStyleDefault`.
@property (nonatomic) PSPDFMediaPlayerControlStyle controlStyle;

/// The range of the video that should be played. You can use this property to truncate
/// parts of the video at the start or at the end. Defaults to a range with start `kCMTimeZero`,
/// and duration `kCMTimeIndefinite`, which means that the entire video will be played from start
/// to end.
/// @note You must set this property before playback starts, otherwise it will have no effect.
@property (nonatomic) CMTimeRange playableRange;

@end

@interface PSPDFMediaPlayerController (Advanced)

/// The internally used player. The `AVPlayer` in use might change during the lifecycle
/// of an `PSPDFMediaPlayerController`! Use with caution!
@property (nonatomic, readonly, nullable) AVPlayer *internalPlayer;

@end

PSPDF_AVAILABLE_DECL @protocol PSPDFMediaPlayerControllerDelegate <NSObject>

@optional

/// Controls whether the media player should pause other instances on play. If this method is not
/// implemented, the default is `YES`.
- (BOOL)mediaPlayerControllerShouldPauseOtherInstances:(PSPDFMediaPlayerController *)controller;

- (void)mediaPlayerControllerDidStartPlaying:(PSPDFMediaPlayerController *)controller;
- (void)mediaPlayerControllerDidPause:(PSPDFMediaPlayerController *)controller;
- (void)mediaPlayerControllerDidFinishPlaying:(PSPDFMediaPlayerController *)controller;
- (void)mediaPlayerController:(PSPDFMediaPlayerController *)controller didHideToolbar:(BOOL)hidden;
- (void)mediaPlayerController:(PSPDFMediaPlayerController *)controller contentStateDidChange:(PSPDFMediaPlayerControllerContentState)contentState;
- (void)mediaPlayerController:(PSPDFMediaPlayerController *)controller externalPlaybackActiveDidChange:(BOOL)externalPlaybackActive;

@end

NS_ASSUME_NONNULL_END
