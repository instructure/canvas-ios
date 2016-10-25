//
//  PSPDFGalleryItem.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFLinkAnnotation;

/// Notification. Posted when the `contentState` of a `PSPDFGalleryItem` changes.
PSPDF_EXPORT NSString *const PSPDFGalleryItemContentStateDidChangeNotification;

typedef NS_ENUM(NSUInteger, PSPDFGalleryItemContentState) {
    /// The item is waiting to load its content.
    PSPDFGalleryItemContentStateWaiting,

    /// The item is currently loading its content.
    PSPDFGalleryItemContentStateLoading,

    /// The item's content is ready.
    PSPDFGalleryItemContentStateReady,

    /// The item has encountered an error while loading its content.
    PSPDFGalleryItemContentStateError
} PSPDF_ENUM_AVAILABLE;

/// Returns a string from `PSPDFGalleryItemContentState`.
PSPDF_EXPORT NSString *NSStringFromPSPDFGalleryItemContentState(PSPDFGalleryItemContentState state);

/// The abstract class for an item in a gallery. Most items will have content that needs to be loaded,
/// hence this class allows for asynchronous state changes. It is the responsibility of the subclass
/// to implement loading, for example by implementing the `PSPDFRemoteContentObject` protocol.
PSPDF_CLASS_AVAILABLE @interface PSPDFGalleryItem : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// @name Item Properties

/// The content URL of the item.
@property (nonatomic, copy, readonly) NSURL *contentURL;

/// The caption of the item.
@property (nonatomic, copy, readonly, nullable) NSString *caption;

/// The options dictionary of the item. Subclasses should implement
/// dedicated setters to access the supported options.
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, id> *options;

/// @name Content

/// The state of the item's content. Defaults to `PSPDFGalleryItemContentStateWaiting`.
@property (nonatomic, readonly) PSPDFGalleryItemContentState contentState;

/// The content of the item. Defaults to `nil`.
@property (nonatomic, readonly, nullable) id content;

/// Indicates if the content of contentURL is considered valid.
@property (nonatomic, readonly, getter=hasValidContent) BOOL validContent;

/// The error that occurred while loading the content. Only valid if `contentState`
/// is `PSPDFGalleryItemContentStateError`.
/// @note This property is not related to the error pointer that can be provided when creating
/// an `PSPDFGalleryItem`.
@property (nonatomic, readonly, nullable) NSError *error;

/// The progress of loading the content. Only valid if `contentState`
/// is `PSPDFGalleryItemContentStateLoading`.
@property (nonatomic, readonly) CGFloat progress;

/// @name Creating Items

/// Factory method to create an array of items from JSON data. Returns `nil` in case of an error.
/// @warning This method may return unresolved gallery items of type `PSPDFGalleryUnknownItem`. It
/// may also not support all features of the gallery. You are strongly encouraged to use
/// `PSPDFGalleryManifest` to instantiate gallery items!
+ (nullable NSArray<PSPDFGalleryItem *> *)itemsFromJSONData:(NSData *)data error:(NSError **)error;

/// Factory method that creates a single gallery item directly from a link annotation.
/// Returns `nil` in case of an error.
/// @warning This method may return unresolved gallery item of type `PSPDFGalleryUnknownItem`. It
/// may also not support all features of the gallery. You are strongly encouraged to use
/// `PSPDFGalleryManifest` to instantiate gallery items!
+ (nullable PSPDFGalleryItem *)itemFromLinkAnnotation:(PSPDFLinkAnnotation *)annotation error:(NSError **)error;

/// Creates an item from a given dictionary. The dictionary will usually be parsed JSON.
/// @warning This method triggers an assertion if `contentURL` is invalid.
/// @note This is the designated initializer.
- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary NS_DESIGNATED_INITIALIZER;

/// Creates an item with the given `contentURL`, `caption` and `options`.
/// `contentURL` is required.
/// `option` takes `PSPDFGalleryItem*` keys.
- (instancetype)initWithContentURL:(NSURL *)contentURL caption:(nullable NSString *)caption options:(nullable NSDictionary<NSString *, id> *)options;

/// @name Options

/// Indicates if the playback controls should be visible. Defaults to `YES`.
@property (nonatomic) BOOL controlsEnabled;

/// Indicates if the content can be presented fullscreen. Defaults to `YES`.
@property (nonatomic, getter=isFullscreenEnabled) BOOL fullscreenEnabled;

@end

@interface PSPDFGalleryItem (Protected)

// Updates `contentState` and posts a `PSPDFGalleryItemContentStateDidChangeNotification` notification.
@property (nonatomic, readwrite) PSPDFGalleryItemContentState contentState;

@property (nonatomic, strong, readwrite, nullable) id content;

@end

/// @name Constants

/// String. The type of an item.
PSPDF_EXPORT NSString *const PSPDFGalleryItemTypeKey;

/// String. The content URL of an item.
PSPDF_EXPORT NSString *const PSPDFGalleryItemContentURLKey;

/// String. The caption of an item.
PSPDF_EXPORT NSString *const PSPDFGalleryItemCaptionKey;

/// String. The options of an item.
PSPDF_EXPORT NSString *const PSPDFGalleryItemOptionsKey;

/// @name Options

/// Boolean. Indicates if the content should automatically start playing.
PSPDF_EXPORT NSString *const PSPDFGalleryOptionAutoplay;

/// Boolean. Indicates if controls should be displayed.
PSPDF_EXPORT NSString *const PSPDFGalleryOptionControls;

/// Boolean. Indicates if the content should loop forever.
PSPDF_EXPORT NSString *const PSPDFGalleryOptionLoop;

/// Boolean. Indicates that the content can be presented fullscreen.
PSPDF_EXPORT NSString *const PSPDFGalleryOptionFullscreen;

NS_ASSUME_NONNULL_END
