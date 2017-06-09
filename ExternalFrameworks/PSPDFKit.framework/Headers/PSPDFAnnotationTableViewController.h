//
//  PSPDFAnnotationTableViewController.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotation.h"
#import "PSPDFOverridable.h"
#import "PSPDFPresentationActions.h"
#import "PSPDFStatefulTableViewController.h"
#import "PSPDFStyleable.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFAnnotation, PSPDFAnnotationTableViewController;

/// Delegate for the `PSPDFAnnotationTableViewController`.
PSPDF_AVAILABLE_DECL @protocol PSPDFAnnotationTableViewControllerDelegate<PSPDFOverridable>

/// Will be called when the user touches an annotation cell.
- (void)annotationTableViewController:(PSPDFAnnotationTableViewController *)annotationController didSelectAnnotation:(PSPDFAnnotation *)annotation;

@end

/**
 Shows an overview of all annotations in the current document.
 @note The toolbar/navigation items are populated in `viewWillAppear:` and can be changed in your subclass.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotationTableViewController : PSPDFStatefulTableViewController<PSPDFStyleable>

/// Convenience initializer. Initializes the view controller with a plain table view style.
- (instancetype)initWithDocument:(nullable PSPDFDocument *)document;

/// Attached PDF document. Can be updated at any time (this will reload the view)
@property (nonatomic, weak) PSPDFDocument *document;

/// The annotation table view delegate.
@property (nonatomic, weak) IBOutlet id<PSPDFAnnotationTableViewControllerDelegate> delegate;

/**
 Set to filter custom annotations. By default this is nil, which means it uses the `editableAnnotationTypes' value of this class.
 This set takes strings like `PSPDFAnnotationStringHighlight`, `PSPDFAnnotationStringInk`, ...
 */
@property (nonatomic, copy, nullable) NSSet<PSPDFAnnotationString> *visibleAnnotationTypes;

/// Usually this property should mirror what is set in `PSPDFConfiguration`.
@property (nonatomic, copy, nullable) NSSet<PSPDFAnnotationString> *editableAnnotationTypes;

/// Allow to long-press to copy the annotation. Defaults to YES.
@property (nonatomic) BOOL allowCopy;

/**
 Allow to delete all annotations via a button. Defaults to YES.
 @note This button is hidden if there are no `editableAnnotationTypes` set in the document.
 */
@property (nonatomic) BOOL showDeleteAllOption;

/**
 Allows search. Defaults to YES.
 The UISearchBar is updated internally during reloading. To customize, use UIAppearance:
 `[[UISearchBar appearanceWhenContainedIn:PSPDFAnnotationTableViewController.class, nil] setBarStyle:UIBarStyleBlack];`
 */
@property (nonatomic) BOOL searchEnabled;

/// Reloads the displayed annotations and updates the internal cache.
- (void)reloadData;

@end

@interface PSPDFAnnotationTableViewController (SubclassingHooks)

/**
 Customize to make more fine-grained changes to the displayed annotation than what would be possible via setting `visibleAnnotationTypes`.
 The result will be cached internally and only refreshed after `reloadData` is called. (the one on this controller, NOT on the table view)
 */
- (NSArray<__kindof PSPDFAnnotation *> *)annotationsForPageAtIndex:(NSUInteger)pageIndex;

/// Queries the cache to get the annotation for `indexPath`.
- (nullable PSPDFAnnotation *)annotationForIndexPath:(NSIndexPath *)indexPath PSPDF_DEPRECATED(6.4, "Use annotationForIndexPath:inTableView: instead.");

/**
 Queries the cache to get the annotation for `indexPath`.

 @param indexPath The index path of the annotation.
 @param tableView The table view of the annotation. Is either equal to `self.tableView` or it is the table view of the search view controller.
 @return The annotation that is shown in the passed in table view at the specified index path.
 */
- (nullable PSPDFAnnotation *)annotationForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;

/// Invoked by the clear all button.
- (IBAction)deleteAllAction:(id)sender;

/**
 Returns a view that wraps the "%tu Annotations" counter.
 Subclass to customize or return something custom/nil.
 */
@property (nonatomic, readonly, nullable) UIView *viewForTableViewFooter;

@end

NS_ASSUME_NONNULL_END
