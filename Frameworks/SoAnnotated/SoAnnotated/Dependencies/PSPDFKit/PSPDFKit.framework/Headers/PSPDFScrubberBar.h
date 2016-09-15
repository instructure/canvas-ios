//
//  PSPDFScrubberBar.h
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
#import "PSPDFPresentationContext.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFScrubberBar;

PSPDF_AVAILABLE_DECL @protocol PSPDFScrubberBarDelegate <NSObject>

- (void)scrubberBar:(PSPDFScrubberBar *)scrubberBar didSelectPage:(NSUInteger)page;

@end

/// PDF thumbnail scrubber bar - similar to iBooks.
PSPDF_CLASS_AVAILABLE @interface PSPDFScrubberBar : UIView <PSPDFCacheDelegate>

/// The delegate for touch events
@property (nonatomic, weak) id <PSPDFScrubberBarDelegate> delegate;

/// The data source.
@property (nonatomic, weak) id <PSPDFPresentationContext> dataSource;

/// Whether this is a horizontally or vertically laid out scrubber bar — defaults to horizontal.
@property (nonatomic) PSPDFScrubberBarType scrubberBarType;

/// Updates toolbar, re-aligns page screenshots. Registers in the runloop and works later.
- (void)updateToolbarAnimated:(BOOL)animated;

/// *Instantly* updates toolbar.
- (void)updateToolbarForced;

/// Updates the page marker.
- (void)updatePageMarker;

/// Current selected page.
@property (nonatomic) NSUInteger page;

/// Taps left/right of the pages area (if there aren't enough pages to fill up space) by default count as first/last page. Defaults to YES.
@property (nonatomic) BOOL allowTapsOutsidePageArea;

/// @name Styling

/// The background tintColor.
/// Defaults to the PSPDFViewController navigationBar barTintColor (if available).
@property (nonatomic, nullable) UIColor *barTintColor UI_APPEARANCE_SELECTOR;

/// If set to a nonzero value, the scrubber bar will render with the standard translucency - blur effect.
/// Inferred from the dataSource by default.
@property (nonatomic, getter=isTranslucent) BOOL translucent UI_APPEARANCE_SELECTOR;

/// Left border margin. Defaults to `thumbnailMargin`. Set higher to allow custom buttons.
@property (nonatomic) CGFloat leftBorderMargin;

/// Right border margin. Defaults to `thumbnailMargin`. Set higher to allow custom buttons.
@property (nonatomic) CGFloat rightBorderMargin;

/// Thumbnail border color. Defaults to [UIColor blackColor].
@property (nonatomic, nullable) UIColor *thumbnailBorderColor UI_APPEARANCE_SELECTOR;

/// Access the internally used toolbar. Can be used to customize the background appearance.
/// @note If you override this to return — e.g. — an instance of a custom toolbar class, be aware that the default implementation makes itself the delegate of the toolbar to support drawing a bezel along the appropriate edge.
@property (nonatomic, readonly) UIToolbar *toolbar;

@end


@interface PSPDFScrubberBar (SubclassingHooks)

/// Returns YES if toolbar is in landscape+iPhone mode.
@property (nonatomic, getter=isSmallToolbar, readonly) BOOL smallToolbar;

/// Returns toolbar height. (depending on `isSmallToolbar`)
@property (nonatomic, readonly) CGFloat scrubberBarHeight;

/// Returns size of the bottom thumbnails. (depending on `isSmallToolbar`)
@property (nonatomic, readonly) CGSize scrubberBarThumbSize;

/// Called once for every thumbnail image.
@property (nonatomic, readonly) UIImageView *emptyThumbnailImageView;

/// Called upon touches and drags on the thumbnails.
- (BOOL)processTouch:(UITouch *)touch;

/// Margin between thumbnails. Defaults to 2.
@property (nonatomic) CGFloat thumbnailMargin;

/// Size multiplier for the current page thumbnail. Defaults to 1.35.
@property (nonatomic) CGFloat pageMarkerSizeMultiplier;

@end

NS_ASSUME_NONNULL_END
