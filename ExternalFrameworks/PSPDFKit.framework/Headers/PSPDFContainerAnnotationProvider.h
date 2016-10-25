//
//  PSPDFContainerAnnotationProvider.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotationProvider.h"
#import "PSPDFUndoProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFUndoController;

/// Default container for annotations. It's crucial that you use this class as your base class if you implement a custom annotation provider, as this class offers efficient undo/redo which otherwise is almost impossible to replicate unless you understand the PSPDFKit internals extremely well.
PSPDF_CLASS_AVAILABLE @interface PSPDFContainerAnnotationProvider : NSObject <PSPDFAnnotationProvider, PSPDFUndoProtocol>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated initializer.
- (instancetype)initWithDocumentProvider:(PSPDFDocumentProvider *)documentProvider NS_DESIGNATED_INITIALIZER;

/// Associated `documentProvider`.
@property (nonatomic, weak, readonly) PSPDFDocumentProvider *documentProvider;

/// Convenience: Attached undo Controller.
@property (nonatomic, weak, readonly) PSPDFUndoController *undoController;

@end

@interface PSPDFContainerAnnotationProvider (SubclassingHooks)

/// Super needs to be called for undo/redo management.
- (nullable NSArray<__kindof PSPDFAnnotation *> *)addAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<NSString *, id> *)options NS_REQUIRES_SUPER;

/// Super needs to be called for undo/redo management.
- (nullable NSArray<__kindof PSPDFAnnotation *> *)removeAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<NSString *, id> *)options NS_REQUIRES_SUPER;

/// Allows synchronization with the internal reader queue.
/// @warning You shouldn't call any of the methods below inside such synchronization blocks, or you will risk a deadlock.
- (void)performBlockForReading:(void (^)(void))block;

/// Allows synchronization with the internal writer queue.
- (void)performBlockForWriting:(void (^)(void))block;

/// Allows synchronization with the internal writer queue and blocks until the block is processed.
- (void)performBlockForWritingAndWait:(void (^)(void))block;

/// Modify the internal store. Optionally appends annotations instead of replacing them.
/// @note The page set in the `annotations` need to match the `page`.
- (void)setAnnotations:(NSArray<PSPDFAnnotation *> *)annotations forPage:(NSUInteger)page append:(BOOL)append;

/// Set annotations, evaluate the page value of each annotation.
- (void)setAnnotations:(NSArray<PSPDFAnnotation *> *)annotations append:(BOOL)append;

/// Remove all annotations (effectively clears the cache).
/// @param options Deletion options (see the `PSPDFAnnotationOption...` constants in `PSPDFAnnotationManager.h`).
- (void)removeAllAnnotationsWithOptions:(NSDictionary<NSString *, id> *)options;

/// Returns all annotations of all pages in one array.
@property (nonatomic, readonly) NSArray<PSPDFAnnotation *> *allAnnotations;

/// Returns all annotations as a page->annotations per page dictionary.
@property (nonatomic, readonly) NSDictionary<NSNumber *, NSArray<PSPDFAnnotation*> *> *annotations;

/// Adding/Removing annotations triggers an internal flag that the provider requires saving.
/// This method can clear this flag.
- (void)clearNeedsSaveFlag;

/// Allows to override the annotation cache directly. Faster than using `setAnnotations:`.
- (void)setAnnotationCacheDirect:(NSDictionary<NSNumber *, NSArray<PSPDFAnnotation *> *> *)annotationCache;

/// Registers annotations for the undo system.
/// @warning Ensure this is called within a write block!
- (void)registerAnnotationsForUndo:(NSArray<PSPDFAnnotation *> *)annotations;

/// Allows to directly access the internally used annotation cache.
/// Be extremely careful when accessing this, and use the locking methods.
@property (nonatomic, readonly) NSMutableDictionary<NSNumber *, NSArray<PSPDFAnnotation *> *> *annotationCache;

/// Called before new annotations are inserted. Subclass to perform custom actions.
- (void)willInsertAnnotations:(NSArray<PSPDFAnnotation *> *)annotations;

@end

NS_ASSUME_NONNULL_END
