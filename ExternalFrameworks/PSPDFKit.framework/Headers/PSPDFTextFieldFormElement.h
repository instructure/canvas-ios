//
//  PSPDFTextFieldFormElement.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFFormElement.h"
#import "PSPDFApplicationJSExport.h"

NS_ASSUME_NONNULL_BEGIN

/// The text field flags. Most flags aren't currently supported.
/// Query `fieldFlags` from the `PSPDFFormElement` base class.
typedef NS_OPTIONS(NSUInteger, PSPDFTextFieldFlag) {
    PSPDFTextFieldFlagMultiline       = 1 << (13-1),
    PSPDFTextFieldFlagPassword        = 1 << (14-1),
    PSPDFTextFieldFlagFileSelect      = 1 << (21-1),
    PSPDFTextFieldFlagDoNotSpellCheck = 1 << (23-1),
    PSPDFTextFieldFlagDoNotScroll     = 1 << (24-1),
    PSPDFTextFieldFlagComb            = 1 << (25-1),
    PSPDFTextFieldFlagRichText        = 1 << (26-1)
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFTextInputFormat) {
    PSPDFTextInputFormatNormal,
    PSPDFTextInputFormatNumber,
    PSPDFTextInputFormatDate,
    PSPDFTextInputFormatTime
} PSPDF_ENUM_AVAILABLE;

/// Text field form element.
PSPDF_CLASS_AVAILABLE @interface PSPDFTextFieldFormElement : PSPDFFormElement

/// If set, the field may contain multiple lines of text; if clear, the field’s text shall be restricted to a single line.
/// @note Evaluates `PSPDFTextFieldFlagMultiline` in the `fieldFlags`.
@property (nonatomic, getter=isMultiline, readonly) BOOL multiline;

/// If set, the field is intended for entering a secure password that should not be echoed visibly to the screen.
/// @note Evaluates `PSPDFTextFieldFlagPassword` in the `fieldFlags`.
@property (nonatomic, getter=isPassword, readonly) BOOL password;

/// Handles Keystroke, Validate and Calculate actions that follow from user text input automatically.
/// `isFinal` defines if the user is typing (NO) or if the string should be committed (YES).
/// The change is the change in text.
/// Returns the new text contents (possibly different from the passed change) to be applied. Otherwise, if failed, returns nil.
- (nullable NSString *)textFieldChangedWithContents:(NSString *)contents change:(NSString *)change range:(NSRange)range isFinal:(BOOL)isFinal application:(nullable id<PSPDFApplicationJSExport>)application error:(NSError * __autoreleasing *)validationError;

/// Returns the contents formatted based on rules in the annotation (including JavaScript)
@property (nonatomic, readonly, nullable) NSString *formattedContents;

/// The input format. Some forms are number/date/time specific.
@property (nonatomic, readonly) PSPDFTextInputFormat inputFormat;

@end

NS_ASSUME_NONNULL_END
