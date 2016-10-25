//
//  PSPDFDocumentSharingViewController.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFStaticTableViewController.h"

#import "PSPDFFile.h"
#import "PSPDFOverridable.h"
#import "PSPDFProcessor.h"
#import "PSPDFStyleable.h"
#import "PSPDFVersion.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument;

typedef NS_OPTIONS(NSUInteger, PSPDFDocumentSharingOptions) {
    /// The default option. Will share all available options via embedding annotations.
    PSPDFDocumentSharingOptionNone                        = 0,

    /// Only page set in `page` of `PSPDFViewController`.
    PSPDFDocumentSharingOptionCurrentPageOnly             = 1 << 0,
    /// Let the user select a range of pages so share.
    PSPDFDocumentSharingOptionPageRange                   = 1 << 1,
    /// Send whole document.
    PSPDFDocumentSharingOptionAllPages                    = 1 << 2,
    /// Share all pages that contain annotations.
    PSPDFDocumentSharingOptionAnnotatedPages              = 1 << 4,
    /// All visible pages. (ignored if only one visible).
    PSPDFDocumentSharingOptionVisiblePages PSPDF_DEPRECATED("5.3", "Use PSPDFDocumentSharingOptionPageRange instead.") = PSPDFDocumentSharingOptionPageRange,

    /// Save annotations in the PDF.
    ///
    /// @warning When using this option for printing, no annotations are printed. This is a result of internal limitations of the printing system on iOS.
    PSPDFDocumentSharingOptionEmbedAnnotations            = 1 << 8,
    /// Render annotations into the PDF.
    PSPDFDocumentSharingOptionFlattenAnnotations          = 1 << 9,
    /// Save annotations + add summary.
    PSPDFDocumentSharingOptionAnnotationsSummary          = 1 << 10,
    /// Remove all annotations.
    PSPDFDocumentSharingOptionRemoveAnnotations           = 1 << 11,

    /// Offer to use the original file for sharing. See `originalFile` in `PSPDFDocument`.
    /// For this option, neither page selection nor annotations apply.
    PSPDFDocumentSharingOptionOriginalFile                = 1 << 16,
    /// Share the current page as an image.
    /// For this option, page selection does not apply.
    PSPDFDocumentSharingOptionImage                       = 1 << 17
} PSPDF_ENUM_AVAILABLE;


static const NSUInteger PSPDFDocumentSharingOptionsPageMask = 0x0000FF;
static const NSUInteger PSPDFDocumentSharingOptionsAnnotationsMask = 0x00FF00;
static const NSUInteger PSPDFDocumentSharingOptionsFileMask = 0xFF0000;

@class PSPDFDocumentSharingViewController;

/// The delegate for the `PSPDFDocumentSharingViewController`.
PSPDF_AVAILABLE_DECL @protocol PSPDFDocumentSharingViewControllerDelegate <PSPDFOverridable>

/// Content has been prepared.
/// `resultingObjects` can either be `NSURL` or `NSData`.
/// Either `files` or `error` is nil.
- (void)documentSharingViewController:(PSPDFDocumentSharingViewController *)shareController didFinishWithSelectedOptions:(PSPDFDocumentSharingOptions)selectedSharingOption files:(nullable NSArray<PSPDFFile *> *)files annotationSummary:(nullable NSAttributedString *)annotationSummary error:(nullable NSError *)error;

@optional

/// Controller has been cancelled.
- (void)documentSharingViewControllerDidCancel:(PSPDFDocumentSharingViewController *)shareController;

/// Commit button has been pressed. Defaults to YES if not implemented.
- (BOOL)documentSharingViewController:(PSPDFDocumentSharingViewController *)shareController shouldPrepareWithSelectedOptions:(PSPDFDocumentSharingOptions)selectedSharingOption selectedPageRange:(NSRange)selectedPageRange;

/// Commit button has been pressed. Defaults to YES if not implemented.
- (BOOL)documentSharingViewController:(PSPDFDocumentSharingViewController *)shareController shouldPrepareWithSelectedOptions:(PSPDFDocumentSharingOptions)selectedSharingOption selectedPages:(NSIndexSet *)selectedPages PSPDF_DEPRECATED(5.3, "Implement documentSharingViewController:shouldPrepareWithSelectedOptions:selectedPageRange: instead.");

/// Can be used to start showing the progress indicator.
/// Will be called both with 0 on start and with 1 when finished.
/// (next to all calls with variable progress)
/// @note Not guaranteed to be called from the main thread.
- (void)documentSharingViewController:(PSPDFDocumentSharingViewController *)shareController preparationProgress:(CGFloat)progress;

/// Allows to override the default title string for a specific option.
/// @note If you implement this method but return nil the default text will be used instead. Return an empty string if you want to display no text.
- (nullable NSString *)documentSharingViewController:(PSPDFDocumentSharingViewController *)shareController titleForOption:(PSPDFDocumentSharingOptions)option;

/// Allows to override the default subtitle string for a specific option.
/// @note If you implement this method but return nil the default text will be used instead. Return an empty string if you want to display no text.
- (nullable NSString *)documentSharingViewController:(PSPDFDocumentSharingViewController *)shareController subtitleForOption:(PSPDFDocumentSharingOptions)option;

/// Allows to return custom options for `PSPDFProcessor`, such as watermarking.
- (void)documentSharingViewController:(PSPDFDocumentSharingViewController *)shareController configureCustomProcessorConfigurationOptions:(PSPDFProcessorConfiguration *)processorConfiguration;

/// Allows specifying custom `PSPDFProcessorSaveOptions`, such as passwords and keylength.
- (PSPDFProcessorSaveOptions *)processorSaveOptionsForDocumentSharingViewController:(PSPDFDocumentSharingViewController *)shareController;

/// Allows to return a custom temporary directory that is used during the export process.
- (nullable NSString *)temporaryDirectoryForDocumentSharingViewController:(PSPDFDocumentSharingViewController *)shareController;

/// Notifies the delegate about the files that the document sharing view controller
/// is about to share.
///
/// You can use this method to alter the files that will be shared.
///
/// @note It is your responsibility to ensure that, when altering the files, the
///       shared files are compatible with the passed in files.
///
/// @param shareController The controller that will share the files.
/// @param files           The files that will be shared.
///
/// @return An array of files that should be shared instead of the passed in ones.
///         If you do not want to alter the files, `files` should be returned.
- (NSArray<PSPDFFile *> *)documentSharingViewController:(PSPDFDocumentSharingViewController *)shareController willShareFiles:(NSArray<PSPDFFile *> *)files;

@end

/// Shows an interface to select the way the PDF should be exported.
/// @note Using the sharing controller will automatically save the document.
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentSharingViewController : PSPDFStaticTableViewController <PSPDFStyleable>

- (instancetype)initWithDocument:(PSPDFDocument *)document visiblePageRange:(NSRange)visiblePageRange allowedSharingOptions:(PSPDFDocumentSharingOptions)sharingOptions NS_DESIGNATED_INITIALIZER;

/// Checks if the controller has options *at all* - and simply calls the delegate if not.
/// This prevents showing the controller without any options and just a commit button.
/// Will return YES if the controller has options available, NO if the delegate has been called.
@property (nonatomic, readonly) BOOL checkIfControllerHasOptionsAvailableAndCallDelegateIfNot;

/// Will take the current settings and start the file crunching. Will call back on the `PSPDFDocumentSharingViewControllerDelegate` unless this returns NO.
@property (nonatomic, readonly) BOOL commitWithCurrentSettings;

/// The current document.
@property (nonatomic, readonly) PSPDFDocument *document;

/// The active sharing option combinations.
/// @warning Modify before the view is loaded.
@property (nonatomic) PSPDFDocumentSharingOptions sharingOptions;

/// Allows to set the default selection. This property will change as the user changes the selection.
/// @note Make sure that `selectedOptions` does not contain any values that are missing from `sharingOptions` or multiple ones per set.
@property (nonatomic) PSPDFDocumentSharingOptions selectedOptions;

/// Button title for "commit".
@property (nonatomic, copy) NSString *commitButtonTitle;

/// The document sharing controller delegate.
@property (nonatomic, weak) IBOutlet id <PSPDFDocumentSharingViewControllerDelegate> delegate;

@end

@interface PSPDFDocumentSharingViewController (SubclassingHooks)

// Will allow the delegate to set custom `PSPDFProcessor` options.
// Subclass this method if you want to add options to all sharing actions.
- (void)delegateConfigureCustomProcessorConfigurationOptions:(PSPDFProcessorConfiguration *)processorConfiguration;

// Will query the delegate for processor save options.
// Subclass this method if you want to add options to all sharing actions.
@property (nonatomic, readonly) PSPDFProcessorSaveOptions *delegateProcessorSaveOptions;

@end


@interface PSPDFDocumentSharingViewController (Deprecated)

/// Initialize with a `document` and optionally `visiblePages`.
/// @note Will be nil if `document` is nil.
- (instancetype)initWithDocument:(PSPDFDocument *)document visiblePages:(nullable NSOrderedSet<NSNumber *> *)visiblePages allowedSharingOptions:(PSPDFDocumentSharingOptions)sharingOptions PSPDF_DEPRECATED(5.3, "Use initWithDocument:visiblePageRange:allowedSharingOptions: instead.");

/// The currently visible page numbers.
/// @warning Modify before the view is loaded.
@property (nonatomic, copy, nullable) NSOrderedSet<NSNumber *> *visiblePages PSPDF_DEPRECATED(5.3, "Set the correct visible pages when calling initWithDocument:visiblePageRange:allowedSharingOptions: instead.");

@end

NS_ASSUME_NONNULL_END
