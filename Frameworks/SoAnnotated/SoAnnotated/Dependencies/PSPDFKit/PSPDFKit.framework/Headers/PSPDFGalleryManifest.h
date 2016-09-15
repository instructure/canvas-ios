//
//  PSPDFGalleryManifest.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFLinkAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^PSPDFGalleryManifestCompletionBlock)(NSArray * _Nullable items, NSError * _Nullable error);

/// `PSPDFGalleryManifest` models the manifest file that is the data source of every gallery.
/// It abstracts the task of loading an array of `PSPDFGalleryItem`s from potentially multiple
/// sources.
PSPDF_CLASS_AVAILABLE @interface PSPDFGalleryManifest : NSObject

/// @name Initialization

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initializes an `PSPDFGalleryManifest` with the given annotation. The annotation is required.
- (instancetype)initWithLinkAnnotation:(PSPDFLinkAnnotation *)linkAnnotation NS_DESIGNATED_INITIALIZER;

/// The link annotation that the manifest was initialized with.
@property (nonatomic, readonly) PSPDFLinkAnnotation *linkAnnotation;

/// @name Item Loading

/// Loads the items from whatever data source the link annotation provides. The completion block
/// will be executed as soon as the load either succeeds or fails.
/// @note If this method is called while a load is already in progress, the method performs a noop
/// and the completion block will never be called.
- (void)loadItemsWithCompletionBlock:(nullable PSPDFGalleryManifestCompletionBlock)completionBlock;

/// Cancels a pending load.
- (void)cancel;

/// Indicates if the manifest is currently loading its items.
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

@end

NS_ASSUME_NONNULL_END
