//
//  PSPDFDocumentDelegate.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFViewController, PSPDFDocumentProvider, PSPDFDocument;

/// Delegate to receive events regarding `PSPDFDocument`.
PSPDF_AVAILABLE_DECL @protocol PSPDFDocumentDelegate <NSObject>

@optional

/// Callback for a render operation. Will be called on a thread (since rendering is async)
/// You can use the context to add custom drawing.
- (void)pdfDocument:(PSPDFDocument *)document didRenderPage:(NSUInteger)page inContext:(CGContextRef)context withSize:(CGSize)fullSize clippedToRect:(CGRect)clipRect annotations:(nullable NSArray<__kindof PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<NSString *, id> *)options;

/// Allow resolving custom path tokens (Documents, Bundle are automatically resolved; you can add e.g. Book and resolve this here). Will only get called for unknown tokens.
- (NSString *)pdfDocument:(PSPDFDocument *)document resolveCustomAnnotationPathToken:(NSString *)pathToken; // return nil if unknown.

/// Called before the save process is started. Will assume YES if not implemented.
/// Might be called multiple times during a save process if the document contains multiple document providers.
/// @warning Might be called from a background thread.
- (BOOL)pdfDocument:(PSPDFDocument *)document provider:(PSPDFDocumentProvider *)documentProvider shouldSaveAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations;

/// Called after saving was successful.
/// If there are no dirty annotations, delegates will not be called.
/// @note `annotations` might not include all changes, especially if annotations have been deleted or an annotation provider didn't implement dirtyAnnotations.
/// @warning Might be called from a background thread.
- (void)pdfDocument:(PSPDFDocument *)document didSaveAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations;

/// Called after saving failed. When an error occurs, annotations will not be the complete set in multi-file documents.
/// @note `annotations` might not include all changes, especially if annotations have been deleted or an annotation provider didn't implement `dirtyAnnotations`.
/// @warning Might be called from a background thread.
- (void)pdfDocument:(PSPDFDocument *)document failedToSaveAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations error:(NSError *)error;

/// Called when an underlying resource of the document is either altered or deleted
/// and the change did not originate from the document itself.
///
/// You can check the `fileURL`'s `-checkResourceIsReachableAndReturnError:` if you
/// want to determine if the file was deleted or updated.
///
/// @note A `PSPDFViewController` does handle this internally already, however if you
///       are creating and modifying `PSPDFDocument`s outside of `PSPDFViewController`,
///       this message is important. If you do not react to this problem correctly,
///       this may result in data loss.
///
/// @param document the document that noticed the change.
/// @param fileURL  the file url pointing to the resource that was changed or deleted.
- (void)pdfDocument:(PSPDFDocument *)document underlyingFileDidChange:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
