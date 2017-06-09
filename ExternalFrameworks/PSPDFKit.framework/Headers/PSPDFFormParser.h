//
//  PSPDFFormParser.h
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

@class PSPDFFormElement, PSPDFDocumentProvider, PSPDFFormField;

NS_ASSUME_NONNULL_BEGIN

/// Parses PDF Forms ("AcroForms").
/// This will not create objects based on the (soon deprecated) XFA standard.
/// @see https://pspdfkit.com/guides/ios/current/rendering-issues/pspdfkit-doesnt-show-the-pdf-form/
PSPDF_CLASS_AVAILABLE @interface PSPDFFormParser : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Attached document provider.
@property (nonatomic, weak, readonly) PSPDFDocumentProvider *documentProvider;

/// A collection of all forms in AcroForm. Lazily evaluated.
@property (nonatomic, copy, readonly) NSArray<__kindof PSPDFFormElement *> *forms;

/// A collection of all form fields in the AcroForm. Lazily evaluated.
@property (nonatomic, copy, readonly, nullable) NSArray<__kindof PSPDFFormField *> *formFields;

/// Return all "dirty" = unsaved form elements
@property (nonatomic, readonly, nullable) NSArray<__kindof PSPDFFormElement *> *dirtyForms;

/// Finds a form element with its field name. Returns nil if not found.
- (nullable __kindof PSPDFFormElement *)findAnnotationWithFieldName:(NSString *)fieldName;

/**
 Finds a form field with the given fully qualified field name.

 @param fullFieldName The fully qualified field name.
 @return The form field, if found. nil otherwise.
 */
- (nullable __kindof PSPDFFormField *)findFieldWithFullFieldName:(NSString *)fullFieldName;

@end

NS_ASSUME_NONNULL_END
