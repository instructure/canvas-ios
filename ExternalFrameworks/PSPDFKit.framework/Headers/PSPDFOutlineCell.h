//
//  PSPDFOutlineCell.h
//  PSPDFKit
//
//  Copyright © 2012-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFTableViewCell.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PSPDFOutlineCell, PSPDFOutlineElement, PSPDFDocumentProvider;

/// The delegate of an outline cell.
PSPDF_AVAILABLE_DECL @protocol PSPDFOutlineCellDelegate<NSObject>

/// Delegate for expand/collapse button.
- (void)outlineCellDidTapDisclosureButton:(PSPDFOutlineCell *)outlineCell;

@end

/// Single cell for the outline controller.
PSPDF_CLASS_AVAILABLE @interface PSPDFOutlineCell : PSPDFTableViewCell

/// Configures the cell. The `documentProvider` is required to resolve the outline actions to page labels.
- (void)configureWithOutlineElement:(PSPDFOutlineElement *)outlineElement documentProvider:(nullable PSPDFDocumentProvider *)documentProvider;

/// Single outline element.
@property (nonatomic, readonly, nullable) PSPDFOutlineElement *outlineElement;

/// The resolved page label.
@property (nonatomic, copy, readonly, nullable) NSString *pageLabelString;

/// Delegate for cell button.
@property (nonatomic, weak) IBOutlet id<PSPDFOutlineCellDelegate> delegate;

/// Shows the expand/collapse button.
@property (nonatomic) BOOL showExpandCollapseButton;

/// Enables the page label on the right side of the cell.
@property (nonatomic) BOOL showPageLabel;

/// :nodoc:
@property (nonatomic, readonly, nullable) UIImageView *imageView NS_UNAVAILABLE;

/// :nodoc:
@property (nonatomic, readonly, nullable) UILabel *textLabel NS_UNAVAILABLE;

/// :nodoc:
@property (nonatomic, readonly, nullable) UILabel *detailTextLabel NS_UNAVAILABLE;

@end

@interface PSPDFOutlineCell (SubclassingHooks)

/// Button that controls expanding and collapsing of cells.
@property (nonatomic) UIButton *disclosureButton;

/// The label displayed containing the outline name.
@property (nonatomic) UILabel *nameLabel;

/// The page label displayed on the right side. Only valid if `showPageLabel` is set.
@property (nonatomic) UILabel *pageLabel;

/**
 Subclass to change the font of `nameLabel`. Default is `UIFontTextStyleSubheadline` for level 0 and `UIFontTextStyleBody` for level > 0.
 This also respects the `fontTraits` of `outlineElement`.
 */
+ (UIFont *)fontForOutlineElement:(nullable PSPDFOutlineElement *)outlineElement;

/// Subclass to change the font of `pageLabel`. Default is `UIFontTextStyleSubheadline`.
+ (UIFont *)pageLabelFontForOutlineElement:(nullable PSPDFOutlineElement *)outlineElement;

/// Set transform according to expansion state.
- (void)updateDisclosureButton;

/// Button action. Animates and calls the delegate.
- (void)expandOrCollapse;

/// Should be changed in `PSPDFOutlineViewController`.
@property (nonatomic) NSUInteger maximumNumberOfLines;

/// Should be changed in `PSPDFOutlineViewController`.
@property (nonatomic) CGFloat outlineIntentLeftOffset;

/// Should be changed in `PSPDFOutlineViewController`.
@property (nonatomic) CGFloat outlineIndentMultiplier;

@end

@interface PSPDFOutlineCell (Deprecated)

/// Dynamically calculates the height for a cell.
+ (CGFloat)heightForCellWithOutlineElement:(PSPDFOutlineElement *)outlineElement documentProvider:(nullable PSPDFDocumentProvider *)documentProvider constrainedToSize:(CGSize)constraintSize outlineIntentLeftOffset:(CGFloat)leftOffset outlineIntentMultiplier:(CGFloat)multiplier showPageLabel:(BOOL)showPageLabel PSPDF_DEPRECATED(6.6, "PSPDFOutlineCell is now a self-sizing table view cell.");

@end

NS_ASSUME_NONNULL_END
