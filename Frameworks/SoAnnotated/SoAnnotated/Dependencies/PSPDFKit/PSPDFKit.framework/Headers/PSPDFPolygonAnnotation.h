//
//  PSPDFPolygonAnnotation.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAbstractLineAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PSPDFPolygonAnnotationIntent) {
    /// No intent.
    PSPDFPolygonAnnotationIntentNone = 0,

    /// The annotation is intended to function as a cloud object.
    PSPDFPolygonAnnotationIntentPolygonCloud,

    /// The polygon annotation is intended to function as a dimension. (not implemented)
    PSPDFPolygonAnnotationIntentPolygonDimension
} PSPDF_ENUM_AVAILABLE;

/// `NSValueTransformer` to convert between `PSPDFPolygonAnnotationIntent` enum and string value.
PSPDF_EXPORT NSString *const PSPDFPolygonAnnotationIntentTransformerName;


/// Polygon annotations (PDF 1.5) display closed polygons on the page. Such polygons may have any number of vertices connected by straight lines. Polyline annotations (PDF 1.5) are similar to polygons, except that the first and last vertex are not implicitly connected.
/// @note See `PSPDFAbstractLineAnnotation` for details how to use and initialize.
PSPDF_CLASS_AVAILABLE @interface PSPDFPolygonAnnotation : PSPDFAbstractLineAnnotation

/// Designated initializer.
- (instancetype)initWithPoints:(NSArray<__kindof NSValue *> *)points intentType:(PSPDFPolygonAnnotationIntent)intentType;

/// Defines the annotation intent. (Optional; PDF 1.6). Defaults to `PSPDFPolygonAnnotationIntentNone`.
@property (nonatomic) PSPDFPolygonAnnotationIntent intentType;

@end

NS_ASSUME_NONNULL_END
