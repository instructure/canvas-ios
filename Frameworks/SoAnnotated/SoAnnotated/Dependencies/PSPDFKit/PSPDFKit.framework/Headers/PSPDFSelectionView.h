//
//  PSPDFSelectionView.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFSelectionView;

PSPDF_AVAILABLE_DECL @protocol PSPDFSelectionViewDelegate <NSObject>

@optional

/// Called before we start selecting. If we return NO here, no selection will be drawn (but delegates will still be displayed)
- (BOOL)selectionView:(PSPDFSelectionView *)selectionView shouldStartSelectionAtPoint:(CGPoint)point;

/// Rect is updated. (`touchesMoved:`)
- (void)selectionView:(PSPDFSelectionView *)selectionView updateSelectedRect:(CGRect)rect;

/// Called when a rect was selected successfully. (`touchesEnded:`)
- (void)selectionView:(PSPDFSelectionView *)selectionView finishedWithSelectedRect:(CGRect)rect;

/// Called when rect selection was cancelled. (`touchesCancelled:`)
- (void)selectionView:(PSPDFSelectionView *)selectionView cancelledWithSelectedRect:(CGRect)rect;

/// Called when we did a single tap in the selection view (via tap gesture recognizer)
- (void)selectionView:(PSPDFSelectionView *)selectionView singleTappedWithGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer;

@end

/// Captures touches and shows selection boxes during dragging.
/// Shows the selection box during dragging when using the highlight or annotation selection tool. (The rectange between the start location of dragging and the current touch location.)
/// With the highlight tool, this also shows the proposed text to be highlighted.
/// With the annotation selection tool, this also shows the proposed selected annotations.
/// The selection color is determined by the `tintColor` property inherited from `UIView`.
/// This is also used for text block debugging.
PSPDF_CLASS_AVAILABLE @interface PSPDFSelectionView : UIView

/// Selection View delegate.
@property (nonatomic, weak) id<PSPDFSelectionViewDelegate> delegate;

/// The selection opacity. Defaults to `UIColor.pspdf_selectionAlpha`.
@property (nonatomic) CGFloat selectionAlpha UI_APPEARANCE_SELECTOR;

/// Allows to mark an array of `CGRects` on the view. `rects` and `rawRects` are mutually exclusive and will nil out each other.
@property (nonatomic, copy, nullable) NSArray *rects;

@end

@interface PSPDFSelectionView (SubclassingHooks)

/// Internal tap gesture.
@property (nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
