//
//  PSPDFAnnotationSet.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFModel.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFAnnotation;

/// An annotation set allows to add and position multiple annotations.
PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotationSet : PSPDFModel <NSFastEnumeration>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated initializer. `annotations` will be a deep copy of the current annotations.
/// The `boundingBox` of the annotations will be normalized. (upper left one will have 0,0 origin)
- (instancetype)initWithAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations NS_DESIGNATED_INITIALIZER;

/// The saved annotations.
@property (nonatomic, copy, readonly) NSArray<__kindof PSPDFAnnotation *> *annotations;

/// Draw all annotations.
- (void)drawInContext:(CGContextRef)context withOptions:(nullable NSDictionary<NSString *, id> *)options;

/// @name Frames

/// Bounding box of all annotations. If set, will correctly resize all annotations.
@property (nonatomic) CGRect boundingBox;

/// @name Clipboard

/// Copies the current set to the clipboard.
- (void)copyToClipboard;

/// Loads a PSPDFAnnotationSet from the clipboard.
/// @note Also supports legacy format and will automatically pack it into a `PSPDFAnnotationSet`.
+ (nullable instancetype)unarchiveFromClipboard;

@end

NS_ASSUME_NONNULL_END
