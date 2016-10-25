//
//  PSPDFSoundAnnotation.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFLinkAnnotation.h"
#import <AVFoundation/AVFoundation.h>
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// List of available encodings. Used in `PSPDFSoundAnnotation.encoding`.
PSPDF_EXPORT NSString *const PSPDFSoundAnnotationEncodingRaw;
PSPDF_EXPORT NSString *const PSPDFSoundAnnotationEncodingSigned;
PSPDF_EXPORT NSString *const PSPDFSoundAnnotationEncodingMuLaw;
PSPDF_EXPORT NSString *const PSPDFSoundAnnotationEncodingALaw;

@class PSPDFSoundAnnotationController;

/// A sound annotation (PDF 1.2) shall analogous to a text annotation except that instead of a text
/// note, it contains sound recorded from the iOS device's microphone or imported from a file.
/// To ensure maximum compatibility set the `boundingBox` for sound annotations to the same size Adobe Acrobat uses (20x15pt).
/// PSPDFKit will always render sound annotations at a fixed size of 74x44pt, centered in the provided `boundingBox`.
PSPDF_CLASS_AVAILABLE @interface PSPDFSoundAnnotation : PSPDFAnnotation

/// Determines if recording annotations are available.
///
/// Recording sound annotations are not available in all environments. E.g. when
/// running inside an App Extension, sound annotations are unavailable as microphone
/// access is disabled.
///
/// @see -initRecorder
///
/// @return `YES` if sound annotations are available, `NO` otherwise.
+ (BOOL)recordingAnnotationAvailable;

// Possible initializers.

/// Initializes an empty sound annotation that can be recorded into.
///
/// @warning Calling this initializer will throw an exception if `+recordingAnnotationAvailable`
///          returns `NO`. Check this method before calling `-initRecorder`.
///
/// @see +recordingAnnotationAvailable
///
/// @return A new, empty instance of `PSPDFSoundAnnotation`.
- (instancetype)initRecorder;

/// Initializes a sound annotation with the sound file located at the given URL.
///
/// Use this method if you want to initialize a sound annotation that already has an existing sound file.
///
/// @param soundURL The file URL to the sound file.
/// @param error    Upon return contains an error if the creation was not possible.
///
/// @return A new sound annotation, ready to be played.
- (instancetype)initWithURL:(NSURL *)soundURL error:(NSError **)error;

/// The annotation controller.
@property (nonatomic, readonly) PSPDFSoundAnnotationController *controller;

/// The sound icon name.
@property (nonatomic, copy, nullable) NSString *iconName;

/// If the annotation is able to record audio
@property (nonatomic, readonly) BOOL canRecord;

/// URL to the sound content.
@property (nonatomic, copy, readonly, nullable) NSURL *soundURL;

/// Bits of the sound stream.
@property (nonatomic, readonly) NSUInteger bits;

/// Sampling rate of the sound stream.
@property (nonatomic, readonly) NSUInteger rate;

/// Channel count of the sound stream.
@property (nonatomic, readonly) NSUInteger channels;

/// Encoding of the sound stream. Use `PSPDFSoundAnnotationEncoding*` for values.
@property (nonatomic, copy, readonly, nullable) NSString *encoding;

/// Loads bits, sample rate, channels, encoding from sound file.
- (BOOL)loadAttributesFromAudioFile:(NSError **)error;

/// Get the direct sound data.
@property (nonatomic, readonly, nullable) NSData *soundData;

@end

@interface PSPDFSoundAnnotation (Deprecated)

- (instancetype)initWithRate:(NSUInteger)rate channels:(uint32_t)channels bits:(uint32_t)bits encoding:(NSString *)encoding PSPDF_DEPRECATED(5.3.4, "This method is deprecated and will go away in one of the next releases.");

@end

NS_ASSUME_NONNULL_END
