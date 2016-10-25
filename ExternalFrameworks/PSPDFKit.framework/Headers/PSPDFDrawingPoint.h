//
//  PSPDFDrawingPoint.h
//  PSPDFKit
//
//  Copyright (c) 2015-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFMacros.h"
#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

NS_ASSUME_NONNULL_BEGIN

/// Models a point used for natural drawing.
/// Use `PSPDFDrawingPointFromCGPoint` to convert from a point with default intensity.
typedef struct {
    /// The location as a regular CGPoint.
    CGPoint location;
    /// The relative thickness of the line at location. Range is 0-1.
    CGFloat intensity;
} PSPDFDrawingPoint;

/// Point at location `CGPointZero` with `intensity` `0.f`.
PSPDF_EXPORT const PSPDFDrawingPoint PSPDFDrawingPointZero;

/// An invalid point with all components set to `NaN`.
PSPDF_EXPORT const PSPDFDrawingPoint PSPDFDrawingPointNull;

/// The default intensity used for legacy lines without explicit intensity data.
PSPDF_EXPORT const CGFloat PSPDFDefaultIntensity;

/// Returns `YES`, if all values are different from `NAN` and `+inf/-inf`.
PSPDF_EXPORT BOOL PSPDFDrawingPointIsValid(PSPDFDrawingPoint point);

/// Yes when the `location` and `intensity` values match.
PSPDF_EXPORT BOOL PSPDFDrawingPointIsEqualToPoint(PSPDFDrawingPoint point, PSPDFDrawingPoint otherPoint);

/// Converts the point into a string representation.
PSPDF_EXPORT NSString *PSPDFDrawingPointToString(PSPDFDrawingPoint point);

/// The reverse operation to `PSPDFDrawingPointToString`. Returns `PSPDFDrawingPointNull` is parsing fails.
PSPDF_EXPORT PSPDFDrawingPoint PSPDFDrawingPointFromString(NSString *string);

/// Creates a new `PSPDFDrawingPoint`.
NS_INLINE PSPDFDrawingPoint PSPDFDrawingPointMake(CGPoint location, CGFloat intensity) {
    return (PSPDFDrawingPoint){location, intensity};
}

/// Creates a new `PSPDFDrawingPoint` from a `CGPoint`, using `PSPDFDefaultIntensity`.
NS_INLINE PSPDFDrawingPoint PSPDFDrawingPointFromCGPoint(CGPoint location) {
    return (PSPDFDrawingPoint){location, PSPDFDefaultIntensity};
}

@interface NSValue (PSPDFModel)

/// Creates a new value object containing the specified drawing point structure.
+ (NSValue *)pspdf_valueWithDrawingPoint:(PSPDFDrawingPoint)point;

/// Returns the drawing point structure representation of the value.
- (PSPDFDrawingPoint)pspdf_drawingPointValue;

@end

NS_ASSUME_NONNULL_END
