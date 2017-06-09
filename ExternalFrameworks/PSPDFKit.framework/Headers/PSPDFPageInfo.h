//
//  PSPDFPageInfo.h
//  PSPDFKit
//
//  Copyright © 2011-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

@class PSPDFAction, PSPDFDocumentProvider;

NS_ASSUME_NONNULL_BEGIN

/// Marks an unused or invalid page number.
static const NSUInteger PSPDFPageNull = NSUIntegerMax;

typedef NS_ENUM(NSUInteger, PSPDFPageTriggerEvent) {
    /// O (0) Action to be performed when the page is opened.
    PSPDFPageTriggerEventOpen,
    /// C (1) Action to be performed when the page is closed.
    PSPDFPageTriggerEventClose
} PSPDF_ENUM_AVAILABLE;

/// Represents PDF page data. Managed within `PSPDFDocumentProvider`.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFPageInfo : NSObject<NSCopying, NSSecureCoding>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Referenced page, relative to the document provider.
@property (nonatomic, readonly) NSUInteger pageIndex;

/// Referenced document provider.
@property (nonatomic, weak, readonly) PSPDFDocumentProvider *documentProvider;

/// Rect of current page.
@property (nonatomic, readonly) CGRect rect;

/// Saved page rotation of current page. Value between 0 and 270.
@property (nonatomic, readonly) NSUInteger rotation;

/// Defines additional page actions.
/// Key is `PSPDFPageTriggerEvent`, value a `PSPDFAction` instance.
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSNumber *, PSPDFAction *> *additionalActions;

/// Returns corrected, rotated bounds of `rect`. Calculated.
@property (nonatomic, readonly) CGRect rotatedRect;

/// Page transform matrix. Calculated.
@property (nonatomic, readonly) CGAffineTransform rotationTransform;

/// Can be used to selectively disable annotation creation on the current page.
/// This feature is a proprietary PSPDFKit extension. To disable annotation creation
/// add a boolean key (`PSPDF:AllowAnnotationCreation`) to the PDF page dictionary and set it to `false`.
@property (nonatomic, readonly) BOOL allowAnnotationCreation;

/// Returns the media box that is set in the PDF. This is in PDF coordinates, straight from the PDF.
/// @Note: This might return CGRectNull if there's no MediaBox set.
@property (nonatomic, readonly) CGRect mediaBox;

/// Returns the crop box that is set in the PDF. This is in PDF coordinates, straight from the PDF.
/// @Note: This might return CGRectNull if there's no CropBox set.
@property (nonatomic, readonly) CGRect cropBox;

@end

/// Convert a view point to a pdf point. `bounds` is from the view. (usually `PSPDFPageView.bounds`)
PSPDF_EXPORT CGPoint PSPDFConvertViewPointToPDFPoint(CGPoint viewPoint, CGRect cropBox, NSUInteger rotation, CGRect bounds);

/// Convert a pdf point to a view point.
PSPDF_EXPORT CGPoint PSPDFConvertPDFPointToViewPoint(CGPoint pdfPoint, CGRect cropBox, NSUInteger rotation, CGRect bounds);

/// Convert a pdf rect to a normalized view rect.
/// @note **Important:** This is **not** a general purpose conversion function from PDF page to UIKit coordinates!
/// If the pdfRect has negative width or height, the results will be unexpected.
PSPDF_EXPORT CGRect PSPDFConvertPDFRectToViewRect(CGRect pdfRect, CGRect cropBox, NSUInteger rotation, CGRect bounds);

/// Convert a view rect to a normalized pdf rect.
/// @note **Important:** This is **not** a general purpose conversion function from UIKit to PDF page coordinates!
/// If the viewRect has negative width or height, the results will be unexpected.
PSPDF_EXPORT CGRect PSPDFConvertViewRectToPDFRect(CGRect viewRect, CGRect cropBox, NSUInteger rotation, CGRect bounds);

NS_ASSUME_NONNULL_END
