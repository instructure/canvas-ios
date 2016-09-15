//
//  PSPDFViewState.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFModel.h"

/// Represents a certain view state (document position, zoom) of a `PSPDFDocument`.
///
/// @note **Important:** If an instance of this class has a `viewPort`, that view port is always defined in the coordinate system of the page.
/// For pages that are rotated by ± 90 degrees, this implies that the aspect ratio of the `viewPort` will appear to be “flipped” compared to the UI.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFViewState : PSPDFModel <NSSecureCoding>

/// Designated initializer.
- (instancetype)initWithPage:(NSUInteger)page viewPort:(CGRect)viewPort NS_DESIGNATED_INITIALIZER;

/// Convenience–/compatibility initializer
- (instancetype)initWithPage:(NSUInteger)page;

/// Visible Page.
@property (readonly, nonatomic) NSUInteger page;

/// The effectively visible rect of the PDF in PDF coordinates — `CGRectNull` if the view was fully visible and not displayed in continuous scrolling mode.
/// @note Due to the nature of continuous scrolling, even a fully zoomed out page can have a view–port.
/// This is necessary to preserve a scrolling offset in documents where more than one page fits on the screen at once.
@property (readonly, nonatomic) CGRect viewPort;

/// Whether or not the receiver has a restorable view port.
@property (readonly, nonatomic) BOOL hasViewPort;

/// Compares the receiver to another viewstate, allowing for the specified leeway if both have a viewport.
/// @param other The object to compare to — may be `nil`.
/// @param leeway How much each dimension of the viewport may differ.
- (BOOL)isEqualToViewState:(PSPDFViewState *)other withAccuracy:(CGFloat)leeway;

@end
