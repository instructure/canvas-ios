//
//  PSPDFDocumentDelegate.h
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

NS_ASSUME_NONNULL_BEGIN

@class PSPDFViewController, PSPDFDocumentProvider, PSPDFDocument, PSPDFAnnotation;

/// Delegate to receive events regarding `PSPDFDocument`.
PSPDF_AVAILABLE_DECL @protocol PSPDFDocumentDelegate<NSObject>

@optional

/**
 Callback for a render operation. Will be called on a thread (since rendering is async)
 You can use the context to add custom drawing.

 @note Rendered pages are cached. If you draw dynamic content, you need to disable caching or invalidate the pages on `PSPDFCache` before a new render request is scheduled.
 @see `- [PSPDFCache invalidateImageFromDocument:invalidateImageFromDocument:pageIndex:]`
 */
- (void)pdfDocument:(PSPDFDocument *)document didRenderPageAtIndex:(NSUInteger)pageIndex inContext:(CGContextRef)context withSize:(CGSize)fullSize clippedToRect:(CGRect)clipRect annotations:(nullable NSArray<__kindof PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<NSString *, id> *)options;

/// Allow resolving custom path tokens (Documents, Bundle are automatically resolved; you can add e.g. Book and resolve this here). Will only get called for unknown tokens.
- (NSString *)pdfDocument:(PSPDFDocument *)document resolveCustomAnnotationPathToken:(NSString *)pathToken; // return nil if unknown.

/**
 Called before the save process is started. Will assume YES if not implemented.
 Might be called multiple times during a save process if the document contains multiple document providers.
 @warning Might be called from a background thread.
 */
- (BOOL)pdfDocument:(PSPDFDocument *)document provider:(PSPDFDocumentProvider *)documentProvider shouldSaveAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations;

/**
 Called after saving was successful.
 If there are no dirty annotations, delegates will not be called.
 @note `annotations` might not include all changes, especially if annotations have been deleted or an annotation provider didn't implement dirtyAnnotations.
 @warning This is called after document providers finish saving annotations, but before the document is saved to disk. Use `pdfDocumentDidSave:` callback if you want to perform any actions after all changes have beed saved to disk.
 @warning Might be called from a background thread.
 */
- (void)pdfDocument:(PSPDFDocument *)document didSaveAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations;

/**
 Called after saving failed. When an error occurs, annotations will not be the complete set in multi-file documents.
 @note `annotations` might not include all changes, especially if annotations have been deleted or an annotation provider didn't implement `dirtyAnnotations`.
 @warning Might be called from a background thread.
 */
- (void)pdfDocument:(PSPDFDocument *)document failedToSaveAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations error:(NSError *)error;

/**
 Called after saving was successful.
 If document wasn't modified, delegates will not be called.
 @warning Might be called from a background thread.
 */
- (void)pdfDocumentDidSave:(PSPDFDocument *)document;

/**
 Called after saving failed.
 @warning Might be called from a background thread.
 */
- (void)pdfDocument:(PSPDFDocument *)document saveDidFailWithError:(NSError *)error;

/**
 Called when an underlying resource of the document is either altered or deleted
 and the change did not originate from the document itself.

 You can check the `fileURL`'s `-[NSURL checkResourceIsReachableAndReturnError:]` if you
 want to determine if the file was deleted or updated.

 @note A `PSPDFViewController` does handle this internally already, however if you
 are creating and modifying `PSPDFDocument`s outside of `PSPDFViewController`,
 this message is important. If you do not react to this problem correctly,
 this may result in data loss.

 @param document the document that noticed the change.
 @param fileURL  the file url pointing to the resource that was changed or deleted.
 */
- (void)pdfDocument:(PSPDFDocument *)document underlyingFileDidChange:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
