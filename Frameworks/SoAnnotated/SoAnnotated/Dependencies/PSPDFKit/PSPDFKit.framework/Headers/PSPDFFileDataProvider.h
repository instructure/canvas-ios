//
//  PSPDFFileDataProvider.h
//  PSPDFModel
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

/// A `PSPDFDataProvider` that acts upon a file.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFFileDataProvider : NSObject <PSPDFDataProvider>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initializes a `PSPDFFileDataProvider` with the given `fileURL`. If the `fileURL` can't be opened, sets error and returns nil.
- (instancetype)initWithFileURL:(NSURL *)fileURL error:(NSError **)error NS_DESIGNATED_INITIALIZER;

/// The fileURL that is being used by this `PSPDFFileDataProvider`
@property (nonatomic, readonly, copy) NSURL *fileURL;

@end

NS_ASSUME_NONNULL_END
