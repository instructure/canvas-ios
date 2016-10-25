//
//  PSPDFAnnotationProvider.h
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

@class PSPDFAnnotation, PSPDFDocumentProvider;
@protocol PSPDFAnnotationProviderChangeNotifier;

NS_ASSUME_NONNULL_BEGIN

/// With the annotation provider, you can mix in PDF annotations from any source (custom database, web, etc)
/// Implement your custom provider class and register it in the `PSPDFAnnotationManager`.
///
/// (Make sure to register the provider in the PSPDFDocument's `didCreateDocumentProvider:` method, since a `PSPDFDocument` can have multiple `PSPDFDocumentProviders` and thus multiple `PSPDFAnnotationProviders` - and they can also be discarded on low memory situations.)
///
/// Ensure everything is thread safe here - methods will be called from any threads and sometimes even concurrently at the same time.
/// (If you're doing parsing, block and then in the queue re-check so you're not parsing multiple times for the same page)
///
/// @note You should always use `PSPDFContainerAnnotationProvider` as the base class for your custom annotation provider.
PSPDF_AVAILABLE_DECL @protocol PSPDFAnnotationProvider <NSObject>


/// Return any annotations that should be displayed on that page.
///
/// @note This method needs to be accessible FROM ANY THREAD.
/// You can block here and do your processing but try to cache the result, this method is called often. (e.g. on every zoom change/rerendering)
/// You're only getting the zero-based page index here. If needed, add a reference to `PSPDFDocumentProvider` during init or query the change notifier delegate.
- (nullable NSArray<__kindof PSPDFAnnotation *> *)annotationsForPage:(NSUInteger)page;

@optional

/// Return YES if `annotationsForPage:` is done preparing the cache, else NO.
/// PSPDFKit will preload/access `annotationsForPage:` in a background thread and then re-access it on the main thread.
/// Defaults to YES if not implemented.
/// @warning You NEED to return YES on this after `annotationsForPage:` has been accessed.
- (BOOL)hasLoadedAnnotationsForPage:(NSUInteger)page;

/// Any annotation that returns YES on `isOverlay` needs a view class to be displayed.
/// Will be called on all `annotationProviders` until someone doesn't return nil.
/// @note If no class is found, the view will be ignored.
- (Class)annotationViewClassForAnnotation:(PSPDFAnnotation *)annotation;

/// Handle adding annotations. A provider can decide that it doesn't want to add this annotation, in that case either don't implement `addAnnotations:` at all or return nil.
/// Return all annotations that are handled by this annotation provider. `PSPDFAnnotationManager` will call all annotation providers in the list until all annotations have been processed.
/// @param annotations An array of PSPDFAnnotation objects to be added.
/// @param options Insertion options (see the `PSPDFAnnotationOption...` constants in `PSPDFAnnotationManager.h`).
/// @note The annotation provider is responsible for emitting then `PSPDFAnnotationsAddedNotification`.
- (nullable NSArray<__kindof PSPDFAnnotation *> *)addAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<NSString *, id> *)options;

/// Handle removing annotations. A provider can decide that it doesn't want to add this annotation, in that case either don't implement `removeAnnotations:` at all or return NO. `PSPDFAnnotationManager` will query all registered `annotationProviders` until one returns YES on this method.
/// @param annotations An array of PSPDFAnnotation objects to be removed.
/// @param options Deletion options (see the `PSPDFAnnotationOption...` constants in `PSPDFAnnotationManager.h`).
/// @note The annotation provider is responsible for emitting then `PSPDFAnnotationsRemovedNotification`.
- (nullable NSArray<__kindof PSPDFAnnotation *> *)removeAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<NSString *, id> *)options;

/// PSPDFKit requests a save. Can be ignored if you're instantly persisting.
/// Event is e.g. fired before the app goes into background, or when `PSPDFViewController` is dismissed.
/// Return NO + error if saving failed.
- (BOOL)saveAnnotationsWithOptions:(nullable NSDictionary<NSString *, id> *)options error:(NSError **)error;

/// Return YES if the provider requires saving.
@property (nonatomic, readonly) BOOL shouldSaveAnnotations;

/// Return all "dirty" = unsaved annotations.
@property (nonatomic, readonly, nullable) NSDictionary<NSNumber *,NSArray<__kindof PSPDFAnnotation *> *> *dirtyAnnotations;

/// Callback if an annotation has been changed by PSPDFKit.
/// This method will be called on ALL annotations, not just the ones that you provided.
- (void)didChangeAnnotation:(PSPDFAnnotation *)annotation keyPaths:(NSArray<NSString *> *)keyPaths options:(nullable NSDictionary<NSString *, id> *)options;

/// Provides a back-channel to PSPDFKit if you need to change annotations on the fly. (e.g. new changes from your server are coming in)
@property (atomic, weak) id<PSPDFAnnotationProviderChangeNotifier> providerDelegate;

@end

/// To be notified on any changes PSPDFKit does on your annotations, implement this notifier.
/// It will be set as soon as your class is added to the `annotationManager`.
PSPDF_AVAILABLE_DECL @protocol PSPDFAnnotationProviderChangeNotifier <NSObject>

/// Call this from your code as soon as annotations change.
/// This method can be called from any thread. (try to avoid the main thread)
///
/// @warning Don't dynamically change the value that `isOverlay` returns, else you'll confuse the updater.
- (void)updateAnnotations:(NSArray<PSPDFAnnotation *> *)annotations animated:(BOOL)animated;

/// Query to get the document provider if this annotation provider is attached to the `PSPDFAnnotationManager`.
@property (nonatomic, readonly, nullable) PSPDFDocumentProvider *parentDocumentProvider;

@end

NS_ASSUME_NONNULL_END
