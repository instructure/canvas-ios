//
//  PSPDFOutlineCell.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PSPDFTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFOutlineCell, PSPDFOutlineElement, PSPDFDocumentProvider;

/// The delegate of an outline cell.
PSPDF_AVAILABLE_DECL @protocol PSPDFOutlineCellDelegate <NSObject>

/// Delegate for expand/collapse button
- (void)outlineCellDidTapDisclosureButton:(PSPDFOutlineCell *)outlineCell;

@end

/// Single cell for the outline controller.
PSPDF_CLASS_AVAILABLE @interface PSPDFOutlineCell : PSPDFTableViewCell

/// Dynamically calculates the height for a cell.
+ (CGFloat)heightForCellWithOutlineElement:(PSPDFOutlineElement *)outlineElement documentProvider:(nullable PSPDFDocumentProvider *)documentProvider constrainedToSize:(CGSize)constraintSize outlineIntentLeftOffset:(CGFloat)leftOffset outlineIntentMultiplier:(CGFloat)multiplier showPageLabel:(BOOL)showPageLabel;

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

@end

@interface PSPDFOutlineCell (SubclassingHooks)

// Button that controls the open/close of cells.
@property (nonatomic) UIButton *disclosureButton;

// The page label displayed on the right side. Only valid if `showPageLabel` is set.
@property (nonatomic) UILabel *pageLabel;

// Subclass to change the font. Default is 17 for level 1; 15 for level > 1.
+ (UIFont *)fontForOutlineElement:(nullable PSPDFOutlineElement *)outlineElement;

// Set transform according to expansion state.
- (void)updateDisclosureButton;

// Button action. Animates and calls the delegate.
- (void)expandOrCollapse;

/// Should be changed in `PSPDFOutlineViewController`.
@property (nonatomic) CGFloat outlineIntentLeftOffset;

/// Should be changed in `PSPDFOutlineViewController`.
@property (nonatomic) CGFloat outlineIndentMultiplier;

@end

NS_ASSUME_NONNULL_END
