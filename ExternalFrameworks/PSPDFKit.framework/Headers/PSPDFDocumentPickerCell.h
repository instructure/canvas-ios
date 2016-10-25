//
//  PSPDFDocumentPickerCell.h
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

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument;

PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentPickerCell : UITableViewCell

/// Set the page rect so that the image coords can be calculated even before the image is rendered/loaded from the cache.
@property (nonatomic) CGRect rotatedPageRect;

/// Page preview image.
@property (nonatomic, nullable) UIImage *pagePreviewImage;
- (void)setPagePreviewImage:(nullable UIImage *)pagePreviewImage animated:(BOOL)animated;

/// Only for reference, not used.
@property (nonatomic, weak) PSPDFDocument *document;
@property (nonatomic) NSUInteger page;

@end

NS_ASSUME_NONNULL_END
