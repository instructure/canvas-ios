//
//  PSPDFThumbnailGridViewCell.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFCache.h"
#import "PSPDFRoundedLabel.h"
#import "PSPDFPageCell.h"

NS_ASSUME_NONNULL_BEGIN

/// The thumbnail cell classed used for the thumbnail grid and thumbnail scroll bar.
/// @note To modify the selection/highlight state, customize `selectedBackgroundView`.
PSPDF_CLASS_AVAILABLE @interface PSPDFThumbnailGridViewCell : PSPDFPageCell <PSPDFCacheDelegate>

/// Referenced document.
@property (nonatomic, nullable) PSPDFDocument *document;

/// Bookmark ribbon image color. Defaults to red.
@property (nonatomic, nullable) UIColor *bookmarkImageColor UI_APPEARANCE_SELECTOR;

@end


@interface PSPDFThumbnailGridViewCell (SubclassingHooks)

/// Allows to update the bookmark image.
@property (nonatomic, readonly, nullable) UIImageView *bookmarkImageView;

/// Updates the page label.
- (void)updatePageLabel;

/// Update bookmark image frame and image visibility.
- (void)updateBookmarkImage;

@end

NS_ASSUME_NONNULL_END

