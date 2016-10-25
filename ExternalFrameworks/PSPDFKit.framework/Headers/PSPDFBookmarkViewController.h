//
//  PSPDFBookmarkViewController.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFStatefulTableViewController.h"
#import "PSPDFStyleable.h"
#import "PSPDFBookmarkCell.h"
#import "PSPDFOverridable.h"
#import "PSPDFConfiguration.h"

@class PSPDFDocument, PSPDFBookmark, PSPDFBookmarkViewController;

NS_ASSUME_NONNULL_BEGIN

/// Delegate for the bookmark controller.
PSPDF_AVAILABLE_DECL @protocol PSPDFBookmarkViewControllerDelegate <PSPDFOverridable>

/// Query the page that should be bookmarked when pressed the [+] button.
- (NSUInteger)currentPageForBookmarkViewController:(PSPDFBookmarkViewController *)bookmarkController;

/// Called when a cell is touched.
- (void)bookmarkViewController:(PSPDFBookmarkViewController *)bookmarkController didSelectBookmark:(PSPDFBookmark *)bookmark;

@end

/// Show list of bookmarks for the current document and allows editing/reordering of the bookmarks.
PSPDF_CLASS_AVAILABLE @interface PSPDFBookmarkViewController : PSPDFStatefulTableViewController <PSPDFBookmarkTableViewCellDelegate, PSPDFStyleable>

/// Designated initializer. `document` can be nil.
- (instancetype)initWithDocument:(nullable PSPDFDocument *)document NS_DESIGNATED_INITIALIZER;

/// Will also reload tableView if changed.
@property (nonatomic, nullable) PSPDFDocument *document;

/// Allow to long-press to copy the title. Defaults to YES.
@property (nonatomic) BOOL allowCopy;

/// Control the sort order. Reordering is only allowed for `PSPDFSortOrderCustom`.
@property (nonatomic) PSPDFSortOrder sortOrder;

/// The bookmark view controller delegate to detect when a bookmark entry is tapped.
@property (nonatomic, weak) IBOutlet id<PSPDFBookmarkViewControllerDelegate> delegate;

@end

@interface PSPDFBookmarkViewController (SubclassingHooks)

- (void)updateBookmarkViewAnimated:(BOOL)animated;
- (void)addBookmarkAction:(nullable id)sender;
- (void)doneAction:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
