//
//  PSPDFFileDataSink.h
//  PSPDFModel
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import "PSPDFMacros.h"
#import "PSPDFDataSink.h"

NS_ASSUME_NONNULL_BEGIN

/// A data sink for a file.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFFileDataSink : NSObject <PSPDFDataSink>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Opens the given file URL for writing. If it can't be opened, returns nil and sets error.
- (instancetype)initWithFileURL:(NSURL *)fileURL options:(PSPDFDataSinkOptions)options error:(NSError *__autoreleasing *)error NS_DESIGNATED_INITIALIZER;

/// The options set in the constructor.
@property (nonatomic, readonly) PSPDFDataSinkOptions options;

/// The file url.
@property (nonatomic, readonly) NSURL *fileURL;

@end

NS_ASSUME_NONNULL_END
