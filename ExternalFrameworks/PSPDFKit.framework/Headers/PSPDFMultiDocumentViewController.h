//
//  PSPDFMultiDocumentViewController.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseViewController.h"
#import "PSPDFDocument.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFMultiDocumentViewController;

/// Delegate for the `PSPDFMultiDocumentViewController`.
PSPDF_AVAILABLE_DECL @protocol PSPDFMultiDocumentViewControllerDelegate <NSObject>

@optional

/// Informs the delegate that the `documents` array is about to change.
- (void)multiPDFController:(PSPDFMultiDocumentViewController *)multiPDFController willChangeDocuments:(NSArray<PSPDFDocument *> *)newDocuments;

/// Informs the delegate that the `documents` array has changed.
- (void)multiPDFController:(PSPDFMultiDocumentViewController *)multiPDFController didChangeDocuments:(NSArray<PSPDFDocument *> *)oldDocuments;

/// Informs the delegate that `visibleDocument` is about to change.
- (void)multiPDFController:(PSPDFMultiDocumentViewController *)multiPDFController willChangeVisibleDocument:(nullable PSPDFDocument *)newDocument;

/// Informs the delegate that `visibleDocument` has changed.
- (void)multiPDFController:(PSPDFMultiDocumentViewController *)multiPDFController didChangeVisibleDocument:(nullable PSPDFDocument *)oldDocument;

@end

/// Allows displaying multiple `PSPDFDocuments`.
PSPDF_CLASS_AVAILABLE @interface PSPDFMultiDocumentViewController : PSPDFBaseViewController

/// Initialize the controller.
/// Set a custom `pdfController` to use a subclass. If nil, a default instance will be created.
- (instancetype)initWithPDFViewController:(nullable PSPDFViewController *)pdfController NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)decoder NS_DESIGNATED_INITIALIZER;

/// Currently visible document.
@property (nonatomic, nullable) PSPDFDocument *visibleDocument;

/// Documents that are currently loaded.
@property (nonatomic, copy) NSArray<PSPDFDocument *> *documents;

/// Delegate to capture events.
@property (nonatomic, weak) IBOutlet id<PSPDFMultiDocumentViewControllerDelegate> delegate;

/// Set to YES to enable automatic state persisting. Will be saved to NSUserDefaults. Defaults to NO.
@property (nonatomic) BOOL enableAutomaticStatePersistence;

/// Persists the state to `NSUserDefaults`.
/// @warning Will only persist file-based documents, not documents based on NSData or CGDataProviders.
- (void)persistState;

/// Restores state from `NSUserDefaults`. Returns YES on success.
/// Will set the visibleDocument that is saved in the state.
@property (nonatomic, readonly) BOOL restoreState;

/// Restores the state and merges with new documents. First document in the array will be visibleDocument.
- (BOOL)restoreStateAndMergeWithDocuments:(NSArray<PSPDFDocument *> *)documents;

/// Defaults to `PSPDFMultiDocumentsPersistKey`.
/// Change if you use multiple instances of `PSPDFMultiDocumentViewController`.
@property (nonatomic, copy) NSString *statePersistenceKey;

/// The embedded `PSPDFViewController`. Access to customize the properties.
@property (nonatomic, readonly) PSPDFViewController *pdfController;

/// A Boolean value specifying whether thumbnail view mode shows pages from all loaded documents.
/// If `YES`, pages are shown from all loaded documents.
/// If `NO`, only pages from the current visible document are shown.
/// Defaults to `NO`.
@property (nonatomic) BOOL thumbnailViewIncludesAllDocuments;

/// A Boolean value specifying whether `title` should be the title of the current visible document, and therefore shown in the navigation bar.
/// Defaults to `NO`, so no title is shown in the navigation bar.
@property (nonatomic) BOOL showTitle;

@end

@interface PSPDFMultiDocumentViewController (SubclassingHooks)

/// Override this initializer to allow all use cases (storyboard loading, etc)
/// @note The `pdfController` argument might be `nil`, but the property of the same name will be non-nil after calling the superclass’s implementation.
- (void)commonInitWithPDFController:(nullable PSPDFViewController *)pdfController NS_REQUIRES_SUPER;

/// Returns the title of the loaded document at a specified index.
/// Can be subclassed to customize what title should be set.
- (NSString *)titleForDocumentAtIndex:(NSUInteger)idx;

@end

NS_ASSUME_NONNULL_END
