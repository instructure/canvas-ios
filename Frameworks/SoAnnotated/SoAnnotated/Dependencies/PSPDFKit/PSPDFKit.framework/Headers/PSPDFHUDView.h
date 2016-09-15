//
//  PSPDFHUDView.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>
#import "PSPDFScrubberBar.h"
#import "PSPDFLabelView.h"
#import "PSPDFPageLabelView.h"
#import "PSPDFThumbnailBar.h"
#import "PSPDFBackForwardButton.h"
#import "PSPDFRelayTouchesView.h"

@class PSPDFDocumentLabelView, PSPDFPageLabelView, PSPDFScrubberBar, PSPDFThumbnailBar, PSPDFDocument;

NS_ASSUME_NONNULL_BEGIN

/// Empty subclass for easier debugging.
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentLabelView : PSPDFLabelView @end

/// The HUD overlay for the `PSPDFViewController`. Contains the thumbnail and page/title label overlays.
PSPDF_CLASS_AVAILABLE @interface PSPDFHUDView : PSPDFRelayTouchesView <PSPDFThumbnailBarDelegate, PSPDFScrubberBarDelegate, PSPDFPageLabelViewDelegate>

/// Convenience initializer.
- (instancetype)initWithFrame:(CGRect)frame dataSource:(id <PSPDFPresentationContext>)dataSource;

/// The data source.
@property (nonatomic, weak) id <PSPDFPresentationContext> dataSource;

/// Force subview updating.
- (void)layoutSubviewsAnimated:(BOOL)animated;

/// Fetches data again
- (void)reloadData;

/// Specifies the distance between the page label and the top of the scrubber bar or the
/// bottom of the screen, depending on whether the scrubber bar is enabled. Defaults to 0,5,10,5.
@property (nonatomic) UIEdgeInsets pageLabelInsets UI_APPEARANCE_SELECTOR;

/// Specifies the distance between the top document label. Defaults to 10,5,0,5.
@property (nonatomic) UIEdgeInsets documentLabelInsets UI_APPEARANCE_SELECTOR;

/// Insets from self.frame when positioning the thumbnail bar. Defaults to 0,0,0,0.
@property (nonatomic) UIEdgeInsets thumbnailBarInsets UI_APPEARANCE_SELECTOR;

/// Insets from self.frame when positioning the scrubber bar. Defaults to 0,0,0,0.
@property (nonatomic) UIEdgeInsets scrubberBarInsets UI_APPEARANCE_SELECTOR;

@end

@interface PSPDFHUDView (Subviews)

/// Document title label view.
@property (nonatomic, readonly) PSPDFDocumentLabelView *documentLabel;

/// Document page label view.
@property (nonatomic, readonly) PSPDFPageLabelView *pageLabel;

/// Scrubber bar. Created lazily. Available if `PSPDFThumbnailBarModeScrubberBar` is set.
@property (nonatomic, readonly) PSPDFScrubberBar *scrubberBar;

/// Thumbnail bar. Created lazily. Available if `PSPDFThumbnailBarModeScrollable` is set.
@property (nonatomic, readonly) PSPDFThumbnailBar *thumbnailBar;

/// Back navigation button (PSPDFAction history). Automatically shown / hidden.
@property (nonatomic, readonly) PSPDFBackForwardButton *backButton;

/// Forward navigation button (PSPDFAction history). Automatically shown / hidden.
@property (nonatomic, readonly) PSPDFBackForwardButton *forwardButton;

@end

@interface PSPDFHUDView (SubclassingHooks)

/// Update these to manually set the frame.
- (void)updateDocumentLabelFrameAnimated:(BOOL)animated;
- (void)updatePageLabelFrameAnimated:(BOOL)animated;
- (void)updateThumbnailBarFrameAnimated:(BOOL)animated;
- (void)updateScrubberBarFrameAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
