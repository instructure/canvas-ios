//
//  PSPDFDocumentEditorConfiguration.h
//  PSPDFKit
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFModel.h"

typedef NS_ENUM(NSInteger, PSPDFDocumentOrientation) {
    PSPDFDocumentOrientationPortrait,
    PSPDFDocumentOrientationLandscape,
} PSPDF_ENUM_AVAILABLE;

@class PSPDFPagePattern, PSPDFPageSize, PSPDFDirectory, PSPDFCompression;

NS_ASSUME_NONNULL_BEGIN

/**
 Configuration options for various document editor controllers.
 @note Set the configuration values before passing this object to view controllers for display.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentEditorConfiguration : NSObject

/// @name Presets

/// A list of predefined page patterns.
@property (nonatomic, null_resettable) NSArray<PSPDFPagePattern *> *pagePatterns;

/**
 A page size that represents a representative page on the current
 Needs to be set based on the current document.
 @note Can't be `nil` if `pageSizes` is empty.
 */
@property (nonatomic, nullable) PSPDFPageSize *currentDocumentPageSize;

/**
 A list of predefined page sizes.
 @note Can't be empty if `currentDocumentPageSize` is `nil`.
 */
@property (nonatomic, null_resettable) NSArray<PSPDFPageSize *> *pageSizes;

/**
 Represents the directory of the current document.
 @note Can't be `nil` if `saveDirectories` is empty.
 */
@property (nonatomic, nullable) PSPDFDirectory *currentDocumentDirectory;

/**
 A list of predefined save directories.
 @note Can't be empty if `currentDocumentDirectory` is `nil`.
 */
@property (nonatomic, null_resettable) NSArray<PSPDFDirectory *> *saveDirectories;

/**
 A list of predefined compressions.
 @note Can't be empty if `selectedCompression` is `nil`.
 */
@property (nonatomic, null_resettable) NSArray<PSPDFCompression *> *compressions;

/// @name Selection

/// The currently selected page pattern. Defaults to nil (no page pattern).
@property (nonatomic, nullable) PSPDFPagePattern *selectedPagePattern;

/**
 The currently selected page size.
 Defaults to `currentDocumentPageSize` if available, otherwise the first item in `pageSizes` is used.
 */
@property (nonatomic, null_resettable) PSPDFPageSize *selectedPageSize;

/// The currently selected page orientation. Defaults to `PSPDFDocumentOrientationPortrait`.
@property (nonatomic) PSPDFDocumentOrientation selectedOrientation;

/**
 The currently selected page background color.
 Setting this to `nil` will result in the default white color being used.
 */
@property (nonatomic, null_resettable) UIColor *selectedColor;

/**
 The currently selected page image.
 Setting this to `nil` will result in no image being used.
 */
@property (nonatomic, nullable) UIImage *selectedImage;

/**
 A page size that represents a the size of the selected image.
 @note Will be `nil` when `selectedImage` is nil.
 */
@property (nonatomic, nullable) PSPDFPageSize *selectedImagePageSize;

/**
 Represents the compression for the selected image.
 @note Will be `nil` when `selectedImage` is nil.
 */
@property (nonatomic, nullable) PSPDFCompression *selectedCompression;

/**
 The currently selected save directory.
 Defaults to `currentDocumentDirectory` if available, otherwise the first item in `saveDirectories` is used.
 */
@property (nonatomic, null_resettable) PSPDFDirectory *selectedSaveDirectory;

/**
 Defines, wheter the image compression should be editable by the user. Defaults to `YES`.
 When set to NO, images will use the default compression of 0.8
 */
@property (nonatomic) BOOL userFacingCompressionEnabled;

@end

/// Represents a page pattern option for new pages.
PSPDF_CLASS_AVAILABLE @interface PSPDFPagePattern : PSPDFModel

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 Initializes a new page pattern with the given identifier.
 Needs to be one of the pattern identifiers defined in `PSPDFNewPageConfiguration.h`.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

/// The identifier, uniquely identifying the pattern.
@property (nonatomic, readonly) NSString *identifier;

/// Localized version of the identifier, suitable for display.
@property (nonatomic, readonly) NSString *localizedName;

/**
 A thumbnail of the pattern
 
 @note this is a pattern in it self, so you need to draw this as a pattern image.
 */
@property (nonatomic, readonly, nullable) UIImage *thumbnail;

@end

/// Represents a page size option for new pages.
PSPDF_CLASS_AVAILABLE @interface PSPDFPageSize : PSPDFModel

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 Returns a new save directory with a `size` and `name`.
 @see initWithSize:name
 */
+ (instancetype)size:(CGSize)size name:(NSString *)name;

/// Initializes a new page size with the given size and (non-localized) name.
- (instancetype)initWithSize:(CGSize)size name:(NSString *)name NS_DESIGNATED_INITIALIZER;

/// The size in pdf points.
@property (nonatomic, readonly) CGSize size;

/// The name for this size configuration.
@property (nonatomic, readonly) NSString *name;

/// Localized version of `name`, suitable for display.
@property (nonatomic, readonly) NSString *localizedName;

/// A localized string representation of the `size`.
@property (nonatomic, readonly) NSString *localizedSize;

/**
 The `size` adjusted for the given `orientation`.
 Makes sure that either the height or width is the larger dimension.
 */
- (CGSize)sizeForOrientation:(PSPDFDocumentOrientation)orientation;

@end

/// Represents a possible destination directory for the save UI.
PSPDF_CLASS_AVAILABLE @interface PSPDFDirectory : PSPDFModel

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Returns a new save directory with a `nil` name.
+ (instancetype)directoryWithPath:(NSString *)path;

/**
 Returns a new save directory with a `path` and `name`.
 @see initWithPath:name:
 */
+ (instancetype)directoryWithPath:(NSString *)path name:(nullable NSString *)name;

/**
 Initializes a save directory with the given path and (non-localized) name.
 You should make sure that the path is valid and writable by the app.
 */
- (instancetype)initWithPath:(NSString *)path name:(nullable NSString *)name NS_DESIGNATED_INITIALIZER;

/// The directory path.
@property (nonatomic, readonly) NSString *path;

/// The name used to identify this directory.
@property (nonatomic, nullable, readonly) NSString *name;

/**
 Localized version of `name`, suitable for display.
 Will return the last path component if `name` is not set.
 */
@property (nonatomic, readonly) NSString *localizedName;

@end

/// Define a compression used for image compression.
PSPDF_CLASS_AVAILABLE @interface PSPDFCompression : PSPDFModel

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 Create a new compression instance.

 @param compression Used compression value.
 @param name Name of this compression configuration.
 */
+ (instancetype)compression:(CGFloat)compression name:(NSString *)name;

/**
 Create a new compression instance.

 @param compression Used compression value.
 @param name Name of the compression.
 */
- (instancetype)initWithCompression:(CGFloat)compression name:(NSString *)name NS_DESIGNATED_INITIALIZER;

/// Used compression value.
@property (nonatomic, readonly) CGFloat compression;

/// The name for this compression configuration.
@property (nonatomic, readonly) NSString *name;

/// Localized version of `name`, suitable for display.
@property (nonatomic, readonly) NSString *localizedName;

@end

/**
 Implemented in classes that use or modify the document editor configuration.
 @see e.g. `PSPDFNewPageViewController`
 */
PSPDF_AVAILABLE_DECL @protocol PSPDFDocumentEditorConfigurationConfigurable<NSObject>

/// Initializes the controller with a document editor configuration.
- (instancetype)initWithDocumentEditorConfiguration:(PSPDFDocumentEditorConfiguration *)configuration;

/// Contains all possible page configuration options.
@property (nonatomic, readonly) PSPDFDocumentEditorConfiguration *documentEditorConfiguration;

@end

NS_ASSUME_NONNULL_END
