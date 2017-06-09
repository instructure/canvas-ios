//
//  PSPDFFormElement.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFMacros.h"
#import "PSPDFResetFormAction.h"
#import "PSPDFWidgetAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFFormField;

typedef NS_OPTIONS(NSUInteger, PSPDFFormElementFlag) {
    /// Form element is readonly.
    PSPDFFormElementFlagReadOnly = 1 << (1 - 1),
    /// Form element is required. (red border)
    PSPDFFormElementFlagRequired = 1 << (2 - 1),
    PSPDFFormElementFlagNoExport = 1 << (3 - 1),
} PSPDF_ENUM_AVAILABLE;

/// Represents a PDF form element.
PSPDF_CLASS_AVAILABLE @interface PSPDFFormElement : PSPDFWidgetAnnotation

/// Returns the form field linked to this annotation.
@property (nonatomic, weak, readonly) PSPDFFormField *formField;

/// Returns true if we can reset this form element to default values.
@property (nonatomic, getter=isResettable, readonly) BOOL resettable;

/// (Optional; inheritable) The default value to which the field reverts when a reset-form action is executed (see 12.7.5.3, “Reset-Form Action”). The format of this value is the same as that of V.
@property (nonatomic, readonly, nullable) id defaultValue;

/// The value which the field is to export when submitted. Can return either a string or an array of strings in the case of multiple selection.
@property (nonatomic, readonly, nullable) id exportValue;

/// Color when the annotation is being highlighted.
/// @note PSPDFKit extension. Won't be saved into the PDF.
@property (nonatomic, nullable) UIColor *highlightColor;

/// The previous control in tab order.
@property (nonatomic, weak) PSPDFFormElement *next;

/// The next control in tab order.
@property (nonatomic, weak) PSPDFFormElement *previous;

// Index of the form to use when determining calculation order when executing calculate actions.
@property (nonatomic, readonly) NSUInteger calculationOrderIndex;

/**
 If set, the user may not change the value of the field. Any associated widget annotations will not interact with the user; that is, they will not respond to mouse clicks or change their appearance in response to mouse motions. This flag is useful for fields whose values are computed or imported from a database.
 This is set by the PDF file and can't be changed by PSPDFKit. See `isEditable` for disabling interaction with the form element.
 */
@property (nonatomic, getter=isReadOnly, readonly) BOOL readOnly;

/**
 If set, the field shall have a value at the time it is exported by a submit- form action (see 12.7.5.2, “Submit-Form Action”).
 This is set by the PDF file and can't be changed by PSPDFKit.
 */
@property (nonatomic, getter=isRequired, readonly) BOOL required;

/**
 If set, the field shall not be exported by a submit-form action (see 12.7.5.2, “Submit-Form Action”).
 This is set by the PDF file and can't be changed by PSPDFKit.
 */
@property (nonatomic, getter=isNoExport, readonly) BOOL noExport;

/// The partial field name.
@property (nonatomic, readonly, nullable) NSString *fieldName;

/// The T entry in the field dictionary (see Table 220) holds a text string defining the field’s partial field name. The fully qualified field name is not explicitly defined but shall be constructed from the partial field names of the field and all of its ancestors. For a field with no parent, the partial and fully qualified names are the same. For a field that is the child of another field, the fully qualified name shall be formed by appending the child field’s partial name to the parent’s
/// fully qualified name, separated by a PERIOD (2Eh) — PDF Spec
@property (nonatomic, readonly, nullable) NSString *fullyQualifiedFieldName;

/// Returns the Form Type Name. "Form Element", "Text Field" etc
@property (nonatomic, readonly) NSString *formTypeName;

@end

@interface PSPDFFormElement (Fonts)

/// The maximum length of the field’s text, in characters. (Optional; inheritable)
@property (nonatomic) NSUInteger maxLength;

/// Properties for rendering
@property (nonatomic) BOOL isMultiline;

@end

@interface PSPDFFormElement (Drawing)

/// Draws the form highlight.
- (void)drawHighlightInContext:(CGContextRef)context options:(nullable NSDictionary *)renderOptions multiply:(BOOL)shouldMultiply;

@end

NS_ASSUME_NONNULL_END
