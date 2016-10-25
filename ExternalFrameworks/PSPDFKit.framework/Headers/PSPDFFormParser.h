//
//  PSPDFFormParser.h
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

@class PSPDFFormElement, PSPDFDocumentProvider;

NS_ASSUME_NONNULL_BEGIN

/// Parses PDF Forms ("AcroForms").
/// This will not create objects based on the (soon deprecated) XFA standard.
/// @see https://pspdfkit.com/guides/ios/current/rendering-issues/pspdfkit-doesnt-show-the-pdf-form/
PSPDF_CLASS_AVAILABLE @interface PSPDFFormParser : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Attached document provider.
@property (nonatomic, weak, readonly) PSPDFDocumentProvider *documentProvider;

/// A collection of all forms in AcroForm. Lazily evaluated.
/// @warning Due to implementation details, make sure you first access the annotations before using this property.
@property (nonatomic, copy, readonly) NSArray<__kindof PSPDFFormElement *> *forms;

/// Return all "dirty" = unsaved form elements
@property (nonatomic, readonly, nullable) NSArray<__kindof PSPDFFormElement *> *dirtyForms;

/// Finds a form element with its field name. Returns nil if not found.
- (nullable __kindof PSPDFFormElement *)findAnnotationWithFieldName:(NSString *)fieldName;

/// Finds a form element with its fully qualified field name. Returns nil if not found.
/// Set the parent to nil to search over all fields.
- (nullable __kindof PSPDFFormElement *)findAnnotationWithFullFieldName:(NSString *)fullFieldName descendingFromForm:(nullable PSPDFFormElement *)parent;

@end

NS_ASSUME_NONNULL_END
