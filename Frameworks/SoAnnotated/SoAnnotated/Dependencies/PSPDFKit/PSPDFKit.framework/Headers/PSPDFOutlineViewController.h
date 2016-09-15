//
//  PSPDFOutlineViewController.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFStatefulTableViewController.h"
#import "PSPDFStyleable.h"
#import "PSPDFOverridable.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFOutlineViewController, PSPDFOutlineElement, PSPDFOutlineCell;

/// Delegate for the `PSPDFOutlineViewController`.
PSPDF_AVAILABLE_DECL @protocol PSPDFOutlineViewControllerDelegate <PSPDFOverridable>

/// Called when we tapped on a cell in the `outlineController`.
/// Return NO if event is not processed.
- (BOOL)outlineController:(PSPDFOutlineViewController *)outlineController didTapAtElement:(PSPDFOutlineElement *)outlineElement;

@end

/// Outline (Table of Contents) view controller.
PSPDF_CLASS_AVAILABLE @interface PSPDFOutlineViewController : PSPDFStatefulTableViewController <UISearchDisplayDelegate, PSPDFStyleable>

/// Initialize the outline controller with a document. `document` can be nil.
- (instancetype)initWithDocument:(nullable PSPDFDocument *)document;

/// Delegate to react when taps are made on outline elements.
@property (nonatomic, weak) IBOutlet id<PSPDFOutlineViewControllerDelegate> delegate;

/// Allow to long-press to copy the title. Defaults to YES.
@property (nonatomic) BOOL allowCopy;

/// Allows search. Defaults to YES.
/// The UISearchBar is updated internally during reloading. To customize, use UIAppearance:
/// `[[UISearchBar appearanceWhenContainedIn:PSPDFOutlineViewController.class, nil] setBarStyle:UIBarStyleBlack];`
@property (nonatomic) BOOL searchEnabled;

/// Enables displaying page labels.
@property (nonatomic) BOOL showPageLabels;

/// How many lines should be displayed for a cell. Defaults to 4. 0 means unlimited.
@property (nonatomic) NSUInteger maximumNumberOfLines;

/// Left intent width. Defaults to 32.f.
@property (nonatomic) CGFloat outlineIntentLeftOffset;

/// Intent multiplier (will be added x times the intent level). Defaults to 15.f.
@property (nonatomic) CGFloat outlineIndentMultiplier;

/// Attached document.
@property (nonatomic, weak) PSPDFDocument *document;

@end


@interface PSPDFOutlineViewController (SubclassingHooks)

/// Cell delegate - expand/shrink content.
- (void)outlineCellDidTapDisclosureButton:(PSPDFOutlineCell *)cell;

/// The search controller used to search the outline.
@property (nonatomic, readonly) UISearchController *searchController;

@end

NS_ASSUME_NONNULL_END
