//
//  PSPDFTextFormField.h
//  PSPDFModel
//
//  Copyright © 2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFFormField.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a text form field in a PDF form. Allows the user to enter custom text.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFTextFormField : PSPDFFormField

PSPDF_EMPTY_INIT_UNAVAILABLE

/// If set, the field may contain multiple lines of text; if clear, the field’s text shall be restricted to a single line.
@property (nonatomic, readonly) BOOL isMultiLine;

/// If set, the field is intended for entering a secure password that should not be echoed visibly to the screen.
@property (nonatomic, readonly) BOOL isPassword;

/// (PDF 1.5) May be set only if the MaxLen entry is present in the text field dictionary (see Table 229) and if the Multiline, Password, and FileSelect flags are clear. If set, the field shall be automatically divided into as many equally spaced positions, or combs, as the value of MaxLen, and the text is laid out into those combs.
@property (nonatomic, readonly) BOOL isComb;

/// (PDF 1.4) If set, the field shall not scroll (horizontally for single-line fields, vertically for multiple-line fields) to accommodate more text than fits within its annotation rectangle. Once the field is full, no further text shall be accepted for interactive form filling; for noninteractive form filling, the filler should take care not to add more character than will visibly fit in the defined area.
@property (nonatomic, readonly) BOOL doNotScroll;

/// (PDF 1.5) If set, the value of this field shall be a rich text string (see 12.7.3.4, “Rich Text Strings”). If the field has a value, the RV entry of the field dictionary (Table 222) shall specify the rich text string.
@property (nonatomic, readonly) BOOL isRichText;

/// (PDF 1.4) If set, text entered in the field shall not be spell-checked.
@property (nonatomic, readonly) BOOL doNotSpellCheck;

/// (PDF 1.4) If set, the text entered in the field represents the pathname of a file whose contents shall be submitted as the value of the field.
@property (nonatomic, readonly) BOOL fileSelect;

/// The text value of the text form field.
@property (nonatomic, copy, nullable) NSString *text;

/// The rich text value of the text form field.
@property (nonatomic, copy, nullable) NSString *richText;

/// The maximum length of the field’s text, in characters. Returns 0 if length is unlimited.
@property (nonatomic, readonly) NSUInteger maxLength;

@end

NS_ASSUME_NONNULL_END
