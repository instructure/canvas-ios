//
//  PSPDFViewState.h
//  PSPDFKit
//
//  Copyright © 2012-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFModel.h"
#import "PSPDFSelectionState.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a certain view state (document position, zoom) of a `PSPDFDocument`.

 @note **Important:** If an instance of this class has a `viewPort`, that view port is always defined in the coordinate system of the page.
 For pages that are rotated by ± 90 degrees, this implies that the aspect ratio of the `viewPort` will appear to be “flipped” compared to the UI.
 */
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFViewState : PSPDFModel<NSSecureCoding>

/// Designated initializer.
- (instancetype)initWithPageIndex:(NSUInteger)pageIndex viewPort:(CGRect)viewPort selectionState:(nullable PSPDFSelectionState *)selectionState NS_DESIGNATED_INITIALIZER;

/// Initializes a PSPDFViewState with the specified page index and selection state only. The view port will be set to CGRectNull.
- (instancetype)initWithPageIndex:(NSUInteger)pageIndex selectionState:(nullable PSPDFSelectionState *)selectionState;

/// Initializes a PSPDFViewState with the specified page index and view port only. The selection state will be set to nil.
- (instancetype)initWithPageIndex:(NSUInteger)pageIndex viewPort:(CGRect)viewPort;

/// Initializes a PSPDFViewState with a page index only. The view port and selection state will be set to CGRectNull and nil respectively.
- (instancetype)initWithPageIndex:(NSUInteger)pageIndex;

/// Visible Page.
@property (readonly, nonatomic) NSUInteger pageIndex;

/**
 The effectively visible rect of the PDF in PDF coordinates — `CGRectNull` if the view was fully visible and not displayed in continuous scrolling mode.
 @note Due to the nature of continuous scrolling, even a fully zoomed out page can have a view–port.
 This is necessary to preserve a scrolling offset in documents where more than one page fits on the screen at once.
 */
@property (readonly, nonatomic) CGRect viewPort;

/// Whether or not the receiver has a restorable view port.
@property (readonly, nonatomic) BOOL hasViewPort;

/// The view's selection state.
@property (readonly, nonatomic, nullable) PSPDFSelectionState *selectionState;

/**
 Compares the receiver to another viewstate, allowing for the specified leeway if both have a viewport.
 @param other The object to compare to — may be `nil`.
 @param leeway How much each dimension of the viewport may differ.
 */
- (BOOL)isEqualToViewState:(nullable PSPDFViewState *)other withAccuracy:(CGFloat)leeway;

@end

NS_ASSUME_NONNULL_END
