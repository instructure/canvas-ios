//
//  PSPDFFreeTextAnnotation.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotation.h"
#import "PSPDFAbstractLineAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

/// The free text annotation intent type. (Optional; PDF 1.6)
typedef NS_ENUM(NSInteger, PSPDFFreeTextAnnotationIntent) {
    /// Regular free text annotation (text box comment)
    PSPDFFreeTextAnnotationIntentFreeText,

    /// Callout style
    PSPDFFreeTextAnnotationIntentFreeTextCallout,

    /// Click- to-type or typewriter object
    PSPDFFreeTextAnnotationIntentFreeTextTypeWriter
} PSPDF_ENUM_AVAILABLE;

/// `NSValueTransformer` to convert between `PSPDFFreeTextAnnotationIntent` enum and string value.
PSPDF_EXPORT NSString *const PSPDFFreeTextAnnotationIntentTransformerName;

/// PDF FreeText Annotation.
///
/// A free text annotation (PDF 1.3) displays text directly on the page. Unlike an ordinary text annotation (see 12.5.6.4, “Text Annotations”), a free text annotation has no open or closed state; instead of being displayed in a pop-up window, the text shall be always visible.
PSPDF_CLASS_AVAILABLE @interface PSPDFFreeTextAnnotation : PSPDFAnnotation

/// Designated initializer.
- (instancetype)initWithContents:(NSString *)contents;

/// Designated initializer for free text callout annotation.
- (instancetype)initWithContents:(NSString *)contents calloutPoint1:(CGPoint)point1;

/// The free text annotation intent type. (Optional; PDF 1.6)
@property (nonatomic) PSPDFFreeTextAnnotationIntent intentType;

/// Starting point for the line if callout is present.
/// @note Shortcut for the first point in the `points` array.
@property (nonatomic) CGPoint point1;

/// Knee point (optional) for the line if callout is present.
/// @note Shortcut for the second point in the `points` array.
@property (nonatomic) CGPoint kneePoint;

/// End point for the line if callout is present.
/// @note Shortcut for the third point in the `points` array.
@property (nonatomic) CGPoint point2;

// Line end type for the callout.
@property (nonatomic) PSPDFLineEndType lineEnd;

/// Defines the inset for the text. Optional, defaults to `UIEdgeInsetsZero`.
/// @note Only positive inset values are allowed.
@property (nonatomic) UIEdgeInsets innerRectInset;

/// Resizes the annotation to fit the entire text by increasing or decreasing the height.
/// The width and origin of the annotation are maintained.
- (void)sizeToFit;

/// Returns the size of the annotation with respect to the given constraints. If you don't want to
/// constrain the height or width, use `CGFLOAT_MAX` for that value. The suggested size does not take the
/// rotation of the annotation into account.
- (CGSize)sizeWithConstraints:(CGSize)constraints;

/// Enables automatic vertical resizing. If this property is set to YES, the annotation will
/// adjust its bounding box as the user types in more text.
/// Defaults to YES.
@property (nonatomic) BOOL enableVerticalResizing;

/// Enables automatic horizontal resizing. If this property is set to YES, the annotation will
/// adjust its bounding box as the user types in more text.
/// Defaults to NO.
@property (nonatomic) BOOL enableHorizontalResizing;

/// Optionally transforms the boundingBox and re-calculates the text size with it.
- (void)setBoundingBox:(CGRect)boundingBox transformSize:(BOOL)transformSize;

/// Bounding box for the inner text box if it's a callout or just a bounding box for the whole annotation
@property (nonatomic) CGRect textBoundingBox;

/// Set size for the text bounding box (PDF coordinates) for the inner text box if it's a callout or just a bounding box size for the whole annotation
- (void)setTextBoundingBoxSize:(CGSize)size;

/// Converts the annotation to the specified intent type.
/// @return A list of property keys that were changed in the process or nil if no change was needed.
- (nullable NSArray<NSString *> *)convertToIntentType:(PSPDFFreeTextAnnotationIntent)intentType;

@end

NS_ASSUME_NONNULL_END
