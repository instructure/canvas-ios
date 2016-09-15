//
//  PSPDFEmbeddedGoToAction.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFGoToAction.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSPDFEmbeddedGoToActionTarget) {
    /// Not yet supported
    PSPDFEmbeddedGoToActionTargetParentOfCurrentDocument,
    PSPDFEmbeddedGoToActionTargetChildOfCurrentDocument
} PSPDF_ENUM_AVAILABLE;

/// An embedded go-to action (PDF 1.6) is similar to a remote go-to action but allows jumping to or from a PDF file that is embedded in another PDF file.
PSPDF_CLASS_AVAILABLE @interface PSPDFEmbeddedGoToAction : PSPDFGoToAction

/// Initialize the embedded GoTo action with a `remotePath` and settings.
- (instancetype)initWithRelativePath:(NSString *)remotePath targetRelationship:(PSPDFEmbeddedGoToActionTarget)targetRelationship openInNewWindow:(BOOL)openInNewWindow pageIndex:(NSUInteger)pageIndex;

/// Target can either be parent or child of the current document. (T.R)
@property (nonatomic, readonly) PSPDFEmbeddedGoToActionTarget targetRelationship;

/// The relative path. Only valid for `PSPDFEmbeddedGoToActionTargetChildOfCurrentDocument`. (T.N)
@property (nonatomic, copy, readonly, nullable) NSString *relativePath;

/// If set to YES, the embedded action will be opened modally. (/NewWindow)
@property (nonatomic, readonly) BOOL openInNewWindow;

// Also uses `pageIndex` from the `PSPDFGoToAction` parent.

@end

NS_ASSUME_NONNULL_END
