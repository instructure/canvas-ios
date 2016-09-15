//
//  PSPDFSearchResultCell.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFKit.h"
#import "PSPDFTableViewCell.h"
#import "PSPDFCache.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFSearchResult;

extern const CGSize PSPDFMaxSearchThumbnailSize;

/// Cell that is used to display a search result.
PSPDF_CLASS_AVAILABLE @interface PSPDFSearchResultCell : PSPDFTableViewCell <PSPDFCacheDelegate>

/// Will configure the cell with a search result model object.
/// @note This method will perform formatting and then calls `configureWithDocument:page:text:detailText:`
- (void)configureWithSearchResult:(PSPDFSearchResult *)searchResult;

/// Will configure the cell with the given document, page, text and detail text.
- (void)configureWithDocument:(PSPDFDocument *)document page:(NSUInteger)page text:(NSString *)text detailText:(nullable NSAttributedString *)detailText;

/// Height calculation.
+ (CGFloat)heightForSearchPreviewText:(NSAttributedString *)text cellWidth:(CGFloat)cellWidth rotatedPageRect:(CGRect)rotatedPageRect maxNumberOfPreviewLines:(NSUInteger)numberOfPreviewLines;

/// Alternative height calculation.
+ (CGFloat)heightForSearchResult:(PSPDFSearchResult *)searchResult cellWidth:(CGFloat)cellWidth maxNumberOfPreviewLines:(NSUInteger)numberOfPreviewLines;

/// The associated document.
@property (nonatomic, weak, readonly) PSPDFDocument *document;

/// The search results page.
@property (nonatomic, readonly) NSUInteger page;

/// Searches the outline for the most matching entry, displays e.g. "Section 100, Page 2" instead of just "Page 2".
/// @note Set before the cell is displayed.
@property (nonatomic) BOOL useOutlineForPageNames;

@end

@interface PSPDFSearchResultCell (SubclassingHooks)

/// Page preview image.
@property (nonatomic) UIImage *pagePreviewImage;

/// The placeholder image displayed while we're loading the page image.
@property (nonatomic, readonly) UIImage *placeholderImage;

/// Fonts used for the labels.
+ (UIFont *)textLabelFont;
+ (UIFont *)detailLabelFont;

@end

NS_ASSUME_NONNULL_END
