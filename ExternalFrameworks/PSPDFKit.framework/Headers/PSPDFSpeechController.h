//
//  PSPDFSpeechController.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Language auto-detection.
PSPDF_EXPORT NSString *const PSPDFSpeechSynthesizerAutoDetectLanguage;

/// Force a specific language.
PSPDF_EXPORT NSString *const PSPDFSpeechSynthesizerLanguageKey;

/// Provide text to sample a language.
PSPDF_EXPORT NSString *const PSPDFSpeechSynthesizerLanguageHintKey;

/// Controls text-to-speech features.
/// @note This class can only be used from the main thread.
PSPDF_CLASS_AVAILABLE @interface PSPDFSpeechController : NSObject

/// Speak string.
/// Setting `language` to nil will use the default language set here.
- (IBAction)speakText:(NSString *)speechString options:(nullable NSDictionary<NSString *, id> *)options delegate:(nullable id<AVSpeechSynthesizerDelegate>)delegate;

/// If this delegate is set, stop current text.
- (BOOL)stopSpeakingForDelegate:(nullable id<AVSpeechSynthesizerDelegate>)delegate;

/// The internally used speech synthesizer.
@property (nonatomic, readonly) AVSpeechSynthesizer *speechSynthesizer;

/// Speech language. Defaults to `PSPDFSpeechSynthesizerAutoDetectLanguage`.
@property (nonatomic, copy) NSString *selectedLanguage;

/// Available language codes, use for `selectedLanguage`.
@property (nonatomic, copy, readonly) NSArray<NSString *> *languageCodes;

/// Speech rate. Defaults to AVSpeechUtteranceDefaultSpeechRate.
@property (nonatomic) float speakRate;

/// Speech pitch. Defaults to 1.0f.
@property (nonatomic) float pitchMultiplier;

@end

NS_ASSUME_NONNULL_END
