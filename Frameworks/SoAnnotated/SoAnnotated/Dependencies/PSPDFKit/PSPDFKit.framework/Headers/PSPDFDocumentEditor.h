//
//  PSPDFDocumentEditor.h
//  PSPDFKit
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

@class PSPDFDocumentEditor, PSPDFDocument, PSPDFEditingChange, PSPDFNewPageConfiguration, PSPDFProcessorSaveOptions;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PSPDFDocumentEditorSaveBlock)(PSPDFDocument * _Nullable document, NSError * _Nullable error);

/// Delegate that can be implemented to be notified of changes that the document editor performs.
PSPDF_AVAILABLE_DECL @protocol PSPDFDocumentEditorDelegate <NSObject>

@optional

/// Called whenever a document operation performs changes.
/// Use the provided `PSPDFEditingChange` objects to update the UI.
- (void)documentEditor:(PSPDFDocumentEditor *)editor didPerformChanges:(NSArray<PSPDFEditingChange *> *)changes;

@end

/// Manages document editing. Supports operations such as remove, move, rotate and add page.
/// @note This class requires the Document Editor component to be enabled for your license.
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentEditor : NSObject

/// Starts an editing session on the document or a new blank editing session.
/// @param document The document used to initialize the document editor or `nil`.
/// If nil, the document editor is initialized with zero pages. If a document is used, it must be a valid document.
/// The changes won't be visible on the document until the document editor is saved.
/// @warning Document editing is currently only supported for documents that contain no annotations or
/// have all annotations embedded in the PDF file. Other annotation providers are not yet supported.
- (nullable instancetype)initWithDocument:(nullable PSPDFDocument *)document NS_DESIGNATED_INITIALIZER;

/// Creates a document editor without a document. Use this to create a new document from scratch.
/// @note You need to add at least one page before saving with `saveToPath:withCompletionBlock:`.
/// An empty document has 0 pages, which does not constitute a valid PDF document.
/// @see initWithDocument:
- (instancetype)init;

/// Reference to the backing document. Will remain nonnull if `initWithDocument:` with a document was used.
/// @see `initWithDocument:`
@property (nonatomic, readonly, nullable) PSPDFDocument *document;

/// Allows you to set security options for saving.
@property (nonatomic, readwrite, nullable) PSPDFProcessorSaveOptions *saveOptions;

/// Adds a document editor delegate to the subscriber list.
/// @note Delegates are weakly retained, but be a good citizen and manually deregister.
- (void)addDelegate:(id <PSPDFDocumentEditorDelegate>)delegate;

/// Removes a document editor delegate from the subscriber list.
- (BOOL)removeDelegate:(id <PSPDFDocumentEditorDelegate>)delegate;

/// @name Page info

/// Returns the page count of the edited Document.
/// If you remove or add pages, this will reflect that change.
@property (nonatomic, readonly) NSUInteger pageCount;

/// Returns the page size, already rotated.
- (CGSize)pageSizeForPage:(NSUInteger)pageIndex;

/// @name Operations

/// Adds a new page at the specified page index, with the configuration options specified in `configuration`.
- (NSArray<PSPDFEditingChange *> *)addPageAt:(NSUInteger)index withConfiguration:(PSPDFNewPageConfiguration *)configuration;

/// Moves pages at the given page indexes to a new page index.
- (NSArray<PSPDFEditingChange *> *)movePages:(NSSet<NSNumber *> *)pageIndexes to:(NSUInteger)destination;

/// Removes pages at the given page indexes.
- (NSArray<PSPDFEditingChange *> *)removePages:(NSSet<NSNumber *> *)pageIndexes;

/// Duplicates pages at the given page indexes. The duplicated pages will be inserted exactly after the original page.
- (NSArray<PSPDFEditingChange *> *)duplicatePages:(NSSet<NSNumber *> *)pageIndexes;

/// Rotates the pages with the given page indexes.
/// Rotation can be 0, 90, 180 and 270. Clockwise and counter-clockwise (depending on the sign).
/// The rotation is added to the current page rotation value.
- (NSArray<PSPDFEditingChange *> *)rotatePages:(NSSet<NSNumber *> *)pageIndexes rotation:(NSInteger)rotation;

/// @name Undo / redo

/// Undoes the last action and returns information about what changed.
- (nullable NSArray<PSPDFEditingChange *> *)undo;

/// Redo the last undo and returns information about what changed.
- (nullable NSArray<PSPDFEditingChange *> *)redo;

/// Checks if you can redo.
@property (nonatomic, readonly) BOOL canRedo;

/// Checks if you can undo.
@property (nonatomic, readonly) BOOL canUndo;

/// @name Save

/// Specifies if it is possible to overwrite the PDF file represented by `document` by invoking
/// `-[PSPDFDocumentEditor save]`. Returns `YES` if the document is backed by a single document provider
/// with a valid and writable file path.
@property (nonatomic, readonly) BOOL canSave;

/// Overwrites the document PDF file and clears the document caches.
/// @note If the `PSPDFDocument` referenced by `document` is currently displayed on a `PDFViewController`,
/// you should call `-[PDFViewController reloadData]` after saving.
/// @warning Don't make any assumptions about the execution context of `block`. Can be called on a background queue.
/// @param block If successful, returns a reference to the current document with cleared caches. Otherwise an error will be available.
/// @see `canSave`
- (void)saveWithCompletionBlock:(nullable PSPDFDocumentEditorSaveBlock)block;

/// Saves the modified document to a new PDF file at `path`.
/// @note This does not affect the `PSPDFDocument` referenced by `document`.
/// @warning Don't make any assumptions about the execution context of `block`. Can be called on a background queue.
/// @param path The destination path for the new document. Should be a directory to which the application can write to.
/// @param block If successful, returns a new document that is configured for the given `path`. Otherwise an
/// error will be available.
- (void)saveToPath:(NSString *)path withCompletionBlock:(nullable PSPDFDocumentEditorSaveBlock)block;

/// Saves the pages listed in `pageIndexes` to a new PDF at `path`.
/// @note This does not affect the `PSPDFDocument` referenced by `document`.
/// @warning Don't make any assumptions about the execution context of `block`. Can be called on a background queue.
/// @param pageIndexes A set of indexes corresponding to pages that should copied to the new document. All indexes need to be bounded by `pageCount`.
/// @param path The destination path for the new document. Should be a directory to which the application can write to.
/// @param block If successful, returns a new document that is configured for the given `path`. Otherwise an
/// error will be available.
- (void)exportPages:(NSSet<NSNumber *> *)pageIndexes toPath:(NSString *)path withCompletionBlock:(nullable PSPDFDocumentEditorSaveBlock)block;

/// @name Rendering

/// Returns the rendered page as an `UIImage` with custom scale.
- (nullable UIImage *)imageForPage:(NSUInteger)pageIndex size:(CGSize)size scale:(CGFloat)scale;

@end

@interface PSPDFDocumentEditor (Deprecated)

/// Returns the rendered page as an `UIImage` with default (device dependent) scale.
- (nullable UIImage *)imageForPage:(NSUInteger)pageIndex size:(CGSize)size PSPDF_DEPRECATED(5.3, "Use variant with scale parameter instead. Default is 0.0");

@end

NS_ASSUME_NONNULL_END
