//
//  PSPDFSoundAnnotationController.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFSoundAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

#define PSPDF_HAS_RECORDING_FEATURE TARGET_OS_IOS || TARGET_OS_OSX

/// Posted when recording or playback is started, paused or stopped.
PSPDF_EXPORT NSNotificationName const PSPDFSoundAnnotationChangedStateNotification;

/// Posted when `+stopRecordingOrPlaybackForAllExcept:` is invoked.
PSPDF_EXPORT NSNotificationName const PSPDFSoundAnnotationStopAllNotification;

typedef NS_ENUM(NSInteger, PSPDFSoundAnnotationState) {
    PSPDFSoundAnnotationStateStopped = 0,
    PSPDFSoundAnnotationStateRecording,
    PSPDFSoundAnnotationStateRecordingPaused,
    PSPDFSoundAnnotationStatePlaying,
    PSPDFSoundAnnotationStatePlaybackPaused,
} PSPDF_ENUM_AVAILABLE;

PSPDF_CLASS_AVAILABLE @interface PSPDFSoundAnnotationController : NSObject

/// Stops any currently active recording or playback, except the sender.
/// If the sender is nil, all annotations are stopped.
+ (void)stopRecordingOrPlaybackForAllExcept:(nullable id)sender;

/// Checks if we have permission to record.
+ (void)requestRecordPermission:(nullable void (^)(BOOL granted))block;

PSPDF_EMPTY_INIT_UNAVAILABLE

- (instancetype)initWithSoundAnnotation:(PSPDFSoundAnnotation *)annotation NS_DESIGNATED_INITIALIZER;

/// The controlled sound annotation.
@property (nonatomic, weak, readonly) PSPDFSoundAnnotation *annotation;

/// The current playback state.
@property (nonatomic, readonly) PSPDFSoundAnnotationState state;

/// The duration of the audio playback
@property (nonatomic, readonly) NSTimeInterval playbackDuration;

/// Starts or resumes playback.
- (BOOL)startPlayback:(NSError **)error;

/// Pauses playback or recording.
- (void)pause;

/// Stops playback or recording.
- (BOOL)stop:(NSError **)error;

#if !TARGET_OS_WATCH

/// The audio player object. Only available if playback is ongoing or prepared.
@property (nonatomic, readonly, nullable) AVAudioPlayer *audioPlayer;

#endif

#if PSPDF_HAS_RECORDING_FEATURE

/// Starts or resumes recording.
- (BOOL)startRecording:(NSError **)error;

/// Discards the current recording.
- (void)discardRecording;

#endif

@end

NS_ASSUME_NONNULL_END
