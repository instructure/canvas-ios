//
//  PSPDFAnnotationManager.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import "PSPDFAnnotation.h"
#import "PSPDFAnnotationProvider.h"

NS_ASSUME_NONNULL_BEGIN

/// Sent when new annotations are added to/removed from the default `PSPDFFileAnnotationProvider`.
PSPDF_EXPORT NSString *const PSPDFAnnotationsAddedNotification;    // object = array of new `PSPDFAnnotation(s)`.
PSPDF_EXPORT NSString *const PSPDFAnnotationsRemovedNotification;  // object = array of removed `PSPDFAnnotation(s)`.

/// Internal events to notify the annotation providers when annotations are being changed.
/// @warning Only send from main thread! Don't call save during a change notification.
PSPDF_EXPORT NSString *const PSPDFAnnotationChangedNotification;                      // object = new `PSPDFAnnotation`.
PSPDF_EXPORT NSString *const PSPDFAnnotationChangedNotificationAnimatedKey;           // set to NO to not animate updates (if it can be animated, that is)
PSPDF_EXPORT NSString *const PSPDFAnnotationChangedNotificationIgnoreUpdateKey;       // set to YES to disable handling by views.
PSPDF_EXPORT NSString *const PSPDFAnnotationChangedNotificationKeyPathKey;            // NSArray of selector names.

/// Marks the inserted annotations as being user created (use a BOOL NSNumber value).
/// @see addAnnotations:options:
PSPDF_EXPORT NSString *const PSPDFAnnotationOptionUserCreatedKey;
/// Prevents the insertion or removal notifications from being sent (use a BOOL NSNumber value).
PSPDF_EXPORT NSString *const PSPDFAnnotationOptionSuppressNotificationsKey;

@protocol PSPDFAnnotationViewProtocol;
@class PSPDFDocumentProvider, PSPDFFileAnnotationProvider;

/// Collects annotations from the various `PSPDFAnnotationProvider` implementations.
///
/// Usually you want to add your custom PSPDFAnnotationProvider instead of subclassing this class.
/// If you subclass, use `overrideClass:withClass:` in `PSPDFDocument`.
///
/// This class will set the `documentProvider` on both annotation adding and retrieving. You don't have to handle this in your `annotationProvider` subclass.
PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotationManager : NSObject <PSPDFAnnotationProviderChangeNotifier>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initializes the annotation manager with the associated `documentProvider`.
- (instancetype)initWithDocumentProvider:(PSPDFDocumentProvider *)documentProvider NS_DESIGNATED_INITIALIZER;


/// The simplest way to extend `PSPDFAnnotationManager` is to register a custom `PSPDFAnnotationProvider`.
/// You can even remove the default `PSPDFFileAnnotationProvider` if you don't want file-based annotations.
///
/// On default, this array will contain the fileAnnotationProvider.
/// @note The order of the array is important.
@property (nonatomic, copy) NSArray<id<PSPDFAnnotationProvider>> *annotationProviders;

/// Direct access to the file annotation provider, who default is the only registered `annotationProvider`.
/// Will never be nil, but can be removed from the `annotationProviders` list.
@property (nonatomic, readonly) PSPDFFileAnnotationProvider *fileAnnotationProvider;

/// Return annotation array for specified page.
///
/// This method will be called OFTEN. Multiple times during a page display, and basically each time you're scrolling or zooming. Ensure it is fast.
/// This will query all annotationProviders and merge the result.
/// For example, to get all annotations except links, use `PSPDFAnnotationTypeAll &~ PSPDFAnnotationTypeLink` as type.
///
/// @note Fetching annotations may take a while. You can do this in a background thread.
- (nullable NSArray<__kindof PSPDFAnnotation *> *)annotationsForPage:(NSUInteger)page type:(PSPDFAnnotationType)type;

/// Returns all annotations of all `annotationProviders`.

/// Returns dictionary `NSNumber`->`NSArray`. Only adds entries for a page if there are annotations.
/// @warning This might take some time if the annotation cache hasn't been built yet.
- (NSDictionary<NSNumber *, NSArray<__kindof PSPDFAnnotation *> *> *)allAnnotationsOfType:(PSPDFAnnotationType)annotationType;

/// YES if annotations are loaded for a specific page.
/// This is used to determine if annotationsForPage:type: should be called directly or in a background thread.
- (BOOL)hasLoadedAnnotationsForPage:(NSUInteger)page;

/// Any annotation that returns YES on `isOverlay` needs a view class to be displayed.
/// Will be called on all `annotationProviders` until someone doesn't return nil.
/// If no class is found, the view will be ignored.
- (nullable Class)annotationViewClassForAnnotation:(PSPDFAnnotation *)annotation;

/// Add `annotations` to the currently set annotation providers.
/// `page` is defined through the set page in each annotation object.
///
/// @param annotations An array of PSPDFAnnotation objects to be added.
/// @param options Insertion options (see the `PSPDFAnnotationOption...` constants in `PSPDFAnnotationManager.h`).
/// @note `PSPDFAnnotationManager` will query all registered annotationProviders until one returns YES on addAnnotations.
///
/// Will return NO if no annotationProvider can handle the annotations. (By default, the `PSPDFFileAnnotationProvider` will handle all annotations.)
///
/// If you're just interested in being notified, you can register a custom `annotationProvider` and set in the array before the file `annotationProvider`. Implement `addAnnotations:` and return NO. You'll be notified of all add operations.
- (BOOL)addAnnotations:(NSArray<PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<NSString *, id> *)options;

/// Remove `annotations` from the pages they are registered in.
/// @param annotations An array of PSPDFAnnotation objects to be removed.
/// @param options Deletion options (see the `PSPDFAnnotationOption...` constants in `PSPDFAnnotationManager.h`).
/// @note Will return NO if no annotationProvider can handle the annotations. (By default, the PSPDFFileAnnotationProvider will handle all annotations.)
- (BOOL)removeAnnotations:(NSArray<PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<NSString *, id> *)options;

/// Will be called by PSPDF internally every time an annotation is changed.
/// Call will be relayed to all `annotationProviders`.
///
/// This method will be called on ALL annotations, not just the ones that you provided.
/// @note If you have custom code that changes annotations and you rely on the `didChangeAnnotation:` event, you need to call it manually.
///
/// `options` is used internally to determine of the file annotation provider should request an annotation update. (the `userInfo` notification dict will be forwarded.)
- (void)didChangeAnnotation:(__kindof PSPDFAnnotation *)annotation keyPaths:(NSArray<NSString *> *)keyPaths options:(nullable NSDictionary<NSString *, id> *)options;

/// Save annotations. (returning NO + eventually an error if it fails)
/// Saving will be forwarded to all annotation providers.
/// Usually you want to override the method in `PSPDFFileAnnotationProvider` instead.
- (BOOL)saveAnnotationsWithOptions:(nullable NSDictionary<NSString *, id> *)options error:(NSError **)error;

/// Return YES if the manager requires saving.
/// @note You should first ensure the `state` property in the `annotationStateManager` to nil to commit any draft annotations.
@property (nonatomic, readonly) BOOL shouldSaveAnnotations;

/// Provided to the `PSPDFAnnotationProviders` via `PSPDFAnnotationProviderChangeNotifier`.
/// Will update any visible annotation.
- (void)updateAnnotations:(NSArray<PSPDFAnnotation *> *)annotations animated:(BOOL)animated;

/// Will parse the annotations in the array and add the ones that are included in the group (have the same grouping ID)
/// `annotations` need to be handled in the annotation manager.
- (NSArray<__kindof PSPDFAnnotation *> *)annotationsIncludingGroupsFromAnnotations:(NSArray<PSPDFAnnotation *> *)annotations;

/// Change the protocol that's used to parse PSPDFKit-additions (links, audio, video). Defaults to `pspdfkit://`.
/// @note This will affect all parsers that generate PSPDFAction objects.
/// @warning Set this early on or manually clear the cache to update the parsers.
@property (nonatomic, copy) NSArray<NSString *> *protocolStrings;

/// The fileType translation table is used when we encounter `pspdfkit://` links (or whatever is set to `document.protocolStrings`)
/// Maps e.g. "mpg" to `PSPDFLinkAnnotationVideo`. (NSString -> NSNumber)
/// @note If you need file translation categorization that is not related to annotations,
/// use `PSPDFFileHelperGetFileCategory()` instead.
+ (NSDictionary<NSString *, NSNumber *> *)fileTypeTranslationTable;

/// Document provider for annotation parser.
@property (nonatomic, weak, readonly) PSPDFDocumentProvider *documentProvider;

@end

@interface PSPDFAnnotationManager (SubclassingHooks)

/// Searches the annotation cache for annotations that have the dirty flag set.
/// Dictionary key are the pages, object an array of annotations.
@property (nonatomic, readonly, nullable) NSDictionary<NSNumber *,NSArray<__kindof PSPDFAnnotation *> *> *dirtyAnnotations;

/// Filtered `fileTypeTranslationTable` that only returns video or audio elements.
+ (NSArray<NSString *> *)mediaFileTypes;

/// Returns the view class that can host the specific annotation subtype.
/// @note Usually you want to write an annotation provider and implement `annotationViewClassForAnnotation:` instead of subclassing.
- (nullable Class)defaultAnnotationViewClassForAnnotation:(PSPDFAnnotation *)annotation;

@end

NS_ASSUME_NONNULL_END

