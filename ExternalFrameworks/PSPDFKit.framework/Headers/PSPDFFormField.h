//
//  PSPDFFormField.h
//  PSPDFModel
//
//  Copyright © 2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFJSONAdapter.h"
#import "PSPDFMacros.h"
#import "PSPDFModel.h"
#import "PSPDFUndoProtocol.h"

@class PSPDFDocumentProvider, PSPDFFormElement;

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, PSPDFFormFieldType) {
    // No form type known.
    PSPDFFormFieldTypeUnknown,
    PSPDFFormFieldTypePushButton,
    PSPDFFormFieldTypeRadioButton,
    PSPDFFormFieldTypeCheckBox,
    PSPDFFormFieldTypeText,
    PSPDFFormFieldTypeListBox,
    PSPDFFormFieldTypeComboBox,
    PSPDFFormFieldTypeSignature,
} PSPDF_ENUM_AVAILABLE;

/// A form field represents one logical field in the PDF form.
/// Use a `PSPDFFormParser` to retrieve them. You can access the form parser from a `PSPDFDocument` or `PSPDFDocumentProvider`.
PSPDF_CLASS_AVAILABLE @interface PSPDFFormField : PSPDFModel<PSPDFUndoProtocol, PSPDFJSONSerializing>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// The document provider that hosts this form field.
@property (nonatomic, readonly, weak) PSPDFDocumentProvider *documentProvider;

/// The type of the form field.
@property (nonatomic, readonly) PSPDFFormFieldType type;

/// The name of the form field.
@property (nonatomic, readonly, nullable) NSString *name;

/**
 The fully qualified name of the form field.
 Form fields can form a hierachy in the PDF form. This combines all the parents names and separates them by a single dot
 to create a string that can uniquely identify a form field across one PDF file.
 */
@property (nonatomic, readonly, nullable) NSString *fullyQualifiedName;

/// (Optional; PDF 1.3) The mapping name that shall be used when exporting interactive form field data from the document.
@property (nonatomic, readonly, nullable) NSString *mappingName;

/// (Optional; PDF 1.3) An alternate field name that shall be used in place of the actual field name wherever the field shall be identified in the user interface (such as in error or status messages referring to the field). This text is also useful when extracting the document’s contents in support of accessibility to users with disabilities or for other purposes (see 14.9.3, “Alternate Descriptions”).
@property (nonatomic, readonly, nullable) NSString *alternateFieldName;

/// Specifies if the linked form elements are editable in the UI. Defaults to YES.
@property (nonatomic) BOOL isEditable;

/**
 If set, the user may not change the value of the field. Any associated widget annotations will not interact with the user; that is, they will not respond to mouse clicks or change their appearance in response to mouse motions. This flag is useful for fields whose values are computed or imported from a database.
 This is set by the PDF file and can't be changed by PSPDFKit. See `isEditable` for disabling interaction with linked form elements.
 */
@property (nonatomic, readonly) BOOL isReadOnly;

/**
 If set, the field shall have a value at the time it is exported by a submit- form action (see 12.7.5.2, “Submit-Form Action”).
 This is set by the PDF file and can't be changed by PSPDFKit.
 */
@property (nonatomic, readonly) BOOL isRequired;

/**
 If set, the field shall not be exported by a submit-form action (see 12.7.5.2, “Submit-Form Action”).
 This is set by the PDF file and can't be changed by PSPDFKit.
 */
@property (nonatomic, readonly) BOOL isNoExport;

/// (Optional; inheritable) The default value to which the field reverts when a reset-form action is executed (see 12.7.5.3, “Reset-Form Action”). The format of this value is the same as that of V.
@property (nonatomic, readonly, nullable) id defaultValue;

/// The value which the field is to export when submitted. Can return either a string or an array of strings in the case of multiple selection.
@property (nonatomic, readonly, nullable) id exportValue;

/// The value of the field. Can either be a `NSString` or a `NSArray` of `NSStrings`.
@property (nonatomic, nullable) id value;

/// Returns the calculation order index.
@property (nonatomic, readonly) NSUInteger calculationOrderIndex;

/// Checks if the form field is dirty.
@property (nonatomic, readonly) BOOL dirty;

/**
 The annotations that represent the visual component of the form field.
 One form field can have more than one annotation. This is mostly used for radio button groups.
 */
@property (nonatomic, readonly) NSArray<__kindof PSPDFFormElement *> *annotations;

/**
 Returns the form name for the given annotation.
 If the `formField` only contains one annotation, the `formField` name will be returned. If it contains multiple
 annotations, a number will be added to the name, according to the PDF standard.
*/
- (nullable NSString *)nameForAnnotation:(PSPDFFormElement *)annotation;

/**
 Returns the fully qualified form name for the given annotation.
 If the `formField` only contains one annotation, the `formField` name will be returned. If it contains multiple
 annotations, a number will be added to the name, according to the PDF standard.
 */
- (nullable NSString *)fullyQualifiedNameForAnnotation:(PSPDFFormElement *)annotation;

@end

NS_ASSUME_NONNULL_END
