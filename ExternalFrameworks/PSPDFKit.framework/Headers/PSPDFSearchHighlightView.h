//
//  PSPDFSearchHighlightView.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotationViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFSearchResult;

/// Highlight view used to show where the search keyword is within the document.
PSPDF_CLASS_AVAILABLE @interface PSPDFSearchHighlightView : UIView <PSPDFAnnotationViewProtocol>

/// Animates the view with a short "pop" size animation.
- (void)popupAnimation;

/// Attached search result.
@property (nonatomic, nullable) PSPDFSearchResult *searchResult;

/// Default background color is yellow, 50% alpha.
@property (nonatomic, nullable) UIColor *selectionBackgroundColor UI_APPEARANCE_SELECTOR;

/// The corner radius of the highlight, expressed as a proportion of its size.
/// The corner radius will be this fraction multiplied by the minimum of the highlight’s width and height.
/// Padding is added to the highlight to ensure rounded corners still cover the selected text.
/// Set to 0 for no corner rounding, and 0.5 for semicircular ends.
/// Defaults to 0.25.
@property (nonatomic) CGFloat cornerRadiusProportion UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
