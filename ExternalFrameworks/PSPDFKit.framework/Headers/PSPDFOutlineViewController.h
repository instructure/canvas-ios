//
//  PSPDFOutlineViewController.h
//  PSPDFKit
//
//  Copyright © 2011-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFOverridable.h"
#import "PSPDFStatefulTableViewController.h"
#import "PSPDFStyleable.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFOutlineViewController, PSPDFOutlineElement, PSPDFOutlineCell;

/// Delegate for the `PSPDFOutlineViewController`.
PSPDF_AVAILABLE_DECL @protocol PSPDFOutlineViewControllerDelegate<PSPDFOverridable>

/**
 Called when a outline element cell is tapped.

 @param outlineController Corresponding `PSPDFOutlineViewController`.
 @param outlineElement Tapped outline element.
 @return Return `NO` if no action was executed, which will then call `outlineCellDidTapDisclosureButton:` if the element is expandable. Return `YES` if an action was executed and no further methods should be called.
 */
- (BOOL)outlineController:(PSPDFOutlineViewController *)outlineController didTapAtElement:(PSPDFOutlineElement *)outlineElement;

@end

/// Outline (Table of Contents) view controller.
PSPDF_CLASS_AVAILABLE @interface PSPDFOutlineViewController : PSPDFStatefulTableViewController<UISearchDisplayDelegate, PSPDFStyleable>

/// Initialize the outline controller with a document. `document` can be `nil`.
- (instancetype)initWithDocument:(nullable PSPDFDocument *)document;

/// Delegate to react when taps are made on outline elements.
@property (nonatomic, weak) IBOutlet id<PSPDFOutlineViewControllerDelegate> delegate;

/// Allow to long-press to copy the title. Defaults to `YES`.
@property (nonatomic) BOOL allowCopy;

/**
 Allows search. Defaults to YES.
 The UISearchBar is updated internally during reloading. To customize, use UIAppearance:
 `[[UISearchBar appearanceWhenContainedIn:PSPDFOutlineViewController.class, nil] setBarStyle:UIBarStyleBlack];`
 */
@property (nonatomic) BOOL searchEnabled;

/// Enables displaying page labels. Defaults to `YES`.
@property (nonatomic) BOOL showPageLabels;

/// How many lines of text should be displayed for each cell. Defaults to 4. Set to 0 for unlimited lines.
@property (nonatomic) NSUInteger maximumNumberOfLines;

/// Left intent width. Defaults to 5.f.
@property (nonatomic) CGFloat outlineIntentLeftOffset;

/// Intent multiplier (will be added x times the intent level). Defaults to 10.f.
@property (nonatomic) CGFloat outlineIndentMultiplier;

/// Attached document.
@property (nonatomic, weak) PSPDFDocument *document;

@end

@interface PSPDFOutlineViewController (SubclassingHooks)

/**
 Outline elements with child elements can also contain a PDF action.
 Elements with an assigned action will trigger the action. Elements without an assigned action will
 just expand/collapse the element. This duality can create a confusing user experience.

 Ideally this is controlled at the PDF authoring stage, however you can also permanently disable invoking actions
 on non-leave nodes by overriding this method and returning `YES`.

 The default implementation of this method returns `NO` which is the standard compliant PDF spec behavior.
 */
@property (nonatomic, readonly) BOOL shouldExpandCollapseOnRowSelection;

/// Cell delegate - expand/shrink content.
- (void)outlineCellDidTapDisclosureButton:(PSPDFOutlineCell *)cell;

/// The search controller used to search the outline.
@property (nonatomic, readonly) UISearchController *searchController;

@end

NS_ASSUME_NONNULL_END
