//
//  PSPDFPageLabelView.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFLabelView.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFPageLabelView;

PSPDF_AVAILABLE_DECL @protocol PSPDFPageLabelViewDelegate <NSObject>

- (void)pageLabelView:(PSPDFPageLabelView *)pageLabelView didPressThumbnailGridButton:(UIButton *)sender;

@end

/// Displays the current page position at the bottom of the screen.
/// @note This class connects to the pdfController via KVO.
PSPDF_CLASS_AVAILABLE @interface PSPDFPageLabelView : PSPDFLabelView

/// Action delegate.
@property (nonatomic, weak) id <PSPDFPageLabelViewDelegate> delegate;

/// Show button to show the thumbnail grid on the right side of the label. Defaults to NO.
@property (nonatomic) BOOL showThumbnailGridButton;

/// The thumbnail grid button, if `showThumbnailGridButton` is enabled.
/// Manually wire up to a target/selector.
@property (nonatomic) UIButton *thumbnailGridButton;

/// Update the page label. Returns YES if label changed.
- (BOOL)updateLabelWithDocument:(PSPDFDocument *)document page:(NSUInteger)page visiblePages:(NSOrderedSet<NSNumber *> *)visiblePages;

@end

@interface PSPDFPageLabelView (SubclassingHooks)

/// Helper that displays the correct page(s) and/or page labels.
- (NSString *)pageLabelWithDocument:(PSPDFDocument *)document page:(NSUInteger)page visiblePages:(NSOrderedSet<NSNumber *> *)visiblePages;

/// Calculates the new frame of this view and its subviews. Subclass to change frame position.
- (void)updateFrame;

@end

NS_ASSUME_NONNULL_END
