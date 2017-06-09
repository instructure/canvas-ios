//
//  PSPDFSelectionState.h
//  PSPDFKit
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFTextSelectionView, PSPDFGlyph, PSPDFImageInfo;

PSPDF_CLASS_AVAILABLE @interface PSPDFSelectionState : NSObject<NSSecureCoding>

/// Returns an instance of the receiver configured to match the selectionView argument's state, if a selection exists.
+ (nullable instancetype)stateForSelectionView:(PSPDFTextSelectionView *)selectionView;

/// The uid of the document which the receiver corresponds to.
@property (nonatomic, readonly) NSString *UID;

/// The page index on which the selection exists.
@property (nonatomic, readonly) NSUInteger selectionPageIndex;

/// The selected glyphs, if any
@property (nonatomic, readonly, nullable) NSArray<PSPDFGlyph *> *selectedGlyphs;

/// The info for the selected image, if any
@property (nonatomic, readonly, nullable) PSPDFImageInfo *selectedImage;

/**
 Returns a Boolean value that indicates whether a selection state is equal to the receiver.

 @param selectionState The selection with which to compare the receiver
 @return YES is `selectionState` is equivalent to the receiver, otherwise NO.
 */
- (BOOL)isEqualToSelectionState:(nullable PSPDFSelectionState *)selectionState;

@end

NS_ASSUME_NONNULL_END
