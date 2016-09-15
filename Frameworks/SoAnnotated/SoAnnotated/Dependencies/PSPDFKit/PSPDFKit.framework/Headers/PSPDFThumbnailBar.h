//
//  PSPDFThumbnailBar.h
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
#import "PSPDFCache.h"
#import "PSPDFPresentationContext.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFThumbnailBar;

/// Delegate for thumbnail actions.
PSPDF_AVAILABLE_DECL @protocol PSPDFThumbnailBarDelegate <NSObject>

@optional

/// A thumbnail has been selected.
- (void)thumbnailBar:(PSPDFThumbnailBar *)thumbnailBar didSelectPage:(NSUInteger)page;

@end

/// Bottom bar that shows a scrollable list of thumbnails.
PSPDF_CLASS_AVAILABLE @interface PSPDFThumbnailBar : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>

/// Delegate for the thumbnail controller.
@property (nonatomic, weak) id<PSPDFThumbnailBarDelegate> thumbnailBarDelegate;

/// The data source.
@property (nonatomic, weak) id <PSPDFPresentationContext> thumbnailBarDataSource;

/// Scrolls to specified page in the grid and centers the selected page.
- (void)scrollToPage:(NSUInteger)page animated:(BOOL)animated;

/// Stops an ongoing scroll animation.
- (void)stopScrolling;

/// Reload and keep the selection
- (void)reloadDataAndKeepSelection;

/// Thumbnail size. Defaults to 88x125 on iPad and 53x75 on iPhone.
@property (nonatomic) CGSize thumbnailSize;

/// Set the default height of the thumbnail bar. Defaults to 135 on iPad and 85 on iPhone.
/// @note Set this before the toolbar is displayed.
@property (nonatomic) CGFloat thumbnailBarHeight;

/// Show page labels. Defaults to NO.
@property (nonatomic) BOOL showPageLabels;

@end

NS_ASSUME_NONNULL_END
