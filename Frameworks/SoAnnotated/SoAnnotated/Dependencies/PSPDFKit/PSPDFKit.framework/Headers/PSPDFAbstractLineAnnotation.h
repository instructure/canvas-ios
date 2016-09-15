//
//  PSPDFAbstractLineAnnotation.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAbstractShapeAnnotation.h"

typedef NS_ENUM(NSInteger, PSPDFLineEndType) {
    PSPDFLineEndTypeNone,
    PSPDFLineEndTypeSquare,
    PSPDFLineEndTypeCircle,
    PSPDFLineEndTypeDiamond,
    PSPDFLineEndTypeOpenArrow,
    PSPDFLineEndTypeClosedArrow,
    PSPDFLineEndTypeButt,
    PSPDFLineEndTypeReverseOpenArrow,
    PSPDFLineEndTypeReverseClosedArrow,
    PSPDFLineEndTypeSlash
} PSPDF_ENUM_AVAILABLE;

NS_ASSUME_NONNULL_BEGIN

/// Base class for Line, Polygon and PolyLine annotations.
PSPDF_CLASS_AVAILABLE @interface PSPDFAbstractLineAnnotation : PSPDFAbstractShapeAnnotation

/// Designated initializer. Requires an array with at least two points.
- (instancetype)initWithPoints:(NSArray<__kindof NSValue *> *)points;

/// Starting line end type.
@property (nonatomic) PSPDFLineEndType lineEnd1;

/// Ending line end type.
@property (nonatomic) PSPDFLineEndType lineEnd2;

/// The path of the line.
/// Might return nil if there are not sufficient points defined in the annotation.
@property (nonatomic, copy, readonly, nullable) UIBezierPath *bezierPath;

/// By default, setting the `boundingBox` will transform the annotation.
/// Use this setter to manually change the boundingBox without changing the points.
- (void)setBoundingBox:(CGRect)boundingBox transformPoints:(BOOL)transformPoints;

/// Call after points have been changed to update the bounding box.
- (void)recalculateBoundingBox;

@end

NS_ASSUME_NONNULL_END
