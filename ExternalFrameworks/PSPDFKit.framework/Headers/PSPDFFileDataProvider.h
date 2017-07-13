//
//  PSPDFFileDataProvider.h
//  PSPDFFoundation
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFDataProvider.h"
#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/// A `PSPDFDataProvider` that acts upon a file.
PSPDF_CLASS_AVAILABLE @interface PSPDFFileDataProvider : NSObject<PSPDFDataProvider>

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 Initializes a `PSPDFFileDataProvider` with the given `fileURL`.
 
 @note If you are expecting to encounter symlinks or alias files, you need to resolve those using `NSURL` APIs before passing the URLs to `PSPDFFileDataProvider`. `PSPDFFileDataProvider` won't automatically resolve them for performance reasons.

 @param fileURL Needs to be a file URL pointing to a PDF file on the filesystem.
 @param baseURL This should mimic the PSPDFDocument value and is important for UID generation.
 @param progress An optionall `NSProgress` instance that indicates progress until the file at `fileURL` can be accessed.
 @return The file provider insteance.
 */
- (instancetype)initWithFileURL:(NSURL *)fileURL baseURL:(nullable NSURL *)baseURL progress:(nullable NSProgress *)progress NS_DESIGNATED_INITIALIZER;

/// @see `initWithFileURL:baseURL:progress:`
- (instancetype)initWithFileURL:(NSURL *)fileURL baseURL:(nullable NSURL *)baseURL;

/// @see `initWithFileURL:baseURL:progress:`
- (nullable instancetype)initWithFileURL:(NSURL *)fileURL;

/// The `fileURL` that is being used by this `PSPDFFileDataProvider`.
@property (nonatomic, readonly) NSURL *fileURL;

/// The `baseURL` if provided during initialization.
@property (nonatomic, readonly, nullable) NSURL *baseURL;

@end

NS_ASSUME_NONNULL_END
