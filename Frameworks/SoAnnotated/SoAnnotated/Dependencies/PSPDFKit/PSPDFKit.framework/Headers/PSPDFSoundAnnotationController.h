//
//  PSPDFSoundAnnotationController.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFSoundAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

/// Posted when recording or playback is started, paused or stopped.
PSPDF_EXPORT NSString *const PSPDFSoundAnnotationChangedStateNotification;

/// Posted when `+stopRecordingOrPlaybackForAllExcept:` is invoked.
PSPDF_EXPORT NSString *const PSPDFSoundAnnotationStopAllNotification;

typedef NS_ENUM(NSInteger, PSPDFSoundAnnotationState) {
    PSPDFSoundAnnotationStateStopped = 0,
    PSPDFSoundAnnotationStateRecording,
    PSPDFSoundAnnotationStateRecordingPaused,
    PSPDFSoundAnnotationStatePlaying,
    PSPDFSoundAnnotationStatePlaybackPaused
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

/// The audio player object. Only available if playback is ongoing or prepared.
@property (nonatomic, readonly, nullable) AVAudioPlayer *audioPlayer;

/// Starts or resumes playback.
- (BOOL)startPlayback:(NSError **)error;

/// Starts or resumes recording.
- (BOOL)startRecording:(NSError **)error;

/// Pauses playback or recording.
- (void)pause;

/// Discards the current recording.
- (void)discardRecording;

/// Stops playback or recording.
- (BOOL)stop:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
