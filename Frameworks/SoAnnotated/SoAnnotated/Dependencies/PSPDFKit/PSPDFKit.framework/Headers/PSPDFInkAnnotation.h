//
//  PSPDFInkAnnotation.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAbstractShapeAnnotation.h"
#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/// PDF Ink Annotation. (Free Drawing)
/// Lines are automatically transformed when the `boundingBox` is changed.
PSPDF_CLASS_AVAILABLE @interface PSPDFInkAnnotation : PSPDFAbstractShapeAnnotation

/// Designated initializer.
/// @param lines Array of arrays of boxed `PSPDFDrawingPoint`.
- (instancetype)initWithLines:(NSArray<NSArray<NSValue *> *> *)lines;

/// Array of arrays of boxed `PSPDFDrawingPoint`.
/// Example: `annotation.lines = @[@[BOXED(PSPDFDrawingPointMake(CGPointMake(100,100) , 0.5f)), BOXED(PSPDFDrawingPointMake((CGPointMake(100,200), 0.5f)), BOXED(PSPDFDrawingPointMake(CGPointMake(150,300), 0.5f))]]`;
/// The intensity values determine the line thickness for natural drawing. 
/// @warning: After setting lines, `boundingBox` will be automatically recalculated.
@property (null_resettable, nonatomic, copy) NSArray<NSArray<NSValue *> *> *lines;

/// The `UIBezierPath` will be dynamically crated from the lines array.
@property (nonatomic, copy, readonly) UIBezierPath *bezierPath;

/// Returns YES if `lines` doesn't contain any points.
@property (nonatomic, getter=isEmpty, readonly) BOOL empty;

/// Will return YES if this ink annotation is in the natural drawing style.
/// This is a proprietary extension - other viewer will not be able to detect this.
@property (nonatomic) BOOL naturalDrawingEnabled;

/// Will return YES if this ink annotation is a PSPDFKit signature.
/// This is a proprietary extension - other viewer will not be able to detect this.
@property (nonatomic) BOOL isSignature;

/// By default, setting the `boundingBox` will transform all points in the lines array.
/// Use this setter to manually change the `boundingBox` without changing lines.
- (void)setBoundingBox:(CGRect)boundingBox transformLines:(BOOL)transformLines;

/// Generate new line array by applying transform.
/// This is used internally when `boundingBox` is changed.
/// @return Either an `NSArray<PSPDFPointArray *>` or an `NSArray<NSArray<NSValue *> *>`.
- (NSArray *)copyLinesByApplyingTransform:(CGAffineTransform)transform;

@end

/// Calculates the bounding box from lines.
/// @param lines Either an `NSArray<PSPDFPointArray *>` or `NSArray>NSArray<NSValue *> *>`.
PSPDF_EXPORT CGRect PSPDFBoundingBoxFromLines(NSArray *lines, CGFloat lineWidth);

/// Will convert view lines to PDF lines (operates on every point)
/// Get the `cropBox` and rotation from `PSPDFPageInfo`.
/// bounds should be the size of the view.
PSPDF_EXPORT NSArray<NSArray<NSValue *> *> *PSPDFConvertViewLinesToPDFLines(NSArray<NSArray<NSValue *> *> *lines, CGRect cropBox, NSUInteger rotation, CGRect bounds);

/// Converts a single line of boxed `PSPDFDrawingPoints`.
PSPDF_EXPORT NSArray<NSValue *> *PSPDFConvertViewLineToPDFLines(NSArray<NSValue *> *line, CGRect cropBox, NSUInteger rotation, CGRect bounds);

/// Will convert PDF lines to view lines (arrays of `PSPDFDrawingPoints`) (operates on every point)
PSPDF_EXPORT NSArray<NSArray<NSValue *> *> *PSPDFConvertPDFLinesToViewLines(NSArray<NSArray<NSValue *> *> *lines, CGRect cropBox, NSUInteger rotation, CGRect bounds);

NS_ASSUME_NONNULL_END
