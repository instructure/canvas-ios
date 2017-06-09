//
//  PSPDFLibraryPreviewResult.h
//  PSPDFModel
//
//  Copyright © 2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFSearchResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This class encapsulates a preview generates by `PSPDFLibrary`.
 Mainly, it prevents access of the `annotation` property of `PSPDFSearchResult`, and instead provides
 an `annotationObjectNumber` property to represent a matched annotation.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFLibraryPreviewResult : PSPDFSearchResult

/// The object number for the matched annotation, if that is what the receiver is representing, `-1` otherwise.
@property (nonatomic, readonly) NSInteger annotationObjectNumber;

/// Returns `YES` if the receiver is representing an annotation search result, else `NO`.
@property (nonatomic, readonly) BOOL isAnnotationResult;

@end

NS_ASSUME_NONNULL_END
