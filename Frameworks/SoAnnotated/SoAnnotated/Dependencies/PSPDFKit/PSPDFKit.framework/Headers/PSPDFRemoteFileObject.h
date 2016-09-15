//
//  PSPDFRemoteFileObject.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFRemoteContentObject.h"
#import "PSPDFFileManager.h"

NS_ASSUME_NONNULL_BEGIN

PSPDF_CLASS_AVAILABLE @interface PSPDFRemoteFileObject : NSObject <PSPDFRemoteContentObject>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated initializer.
- (instancetype)initWithRemoteURL:(NSURL *)remoteURL targetURL:(NSURL *)targetFileURL fileManager:(id<PSPDFFileManager>)fileManager NS_DESIGNATED_INITIALIZER;

/// The remote URL to fetch the content from.
@property (nonatomic, copy, readonly) NSURL *remoteURL;
@property (nonatomic, copy, readonly) NSURL *targetURL;

/// @name PSPDFRemoteContentObject

/// The remote content of the object. This property is managed by `PSPDFDownloadManager`.
@property (nonatomic, nullable) NSURL *remoteContent;

/// The loading state of the object. This property is managed by `PSPDFDownloadManager`.
@property (nonatomic, getter = isLoadingRemoteContent) BOOL loadingRemoteContent;

/// The download progress of the object. Only meaningful if `loadingRemoteContent` is YES.
/// This property is managed by `PSPDFDownloadManager`.
@property (nonatomic) CGFloat remoteContentProgress;

/// The remote content error of the object. This property is managed by `PSPDFDownloadManager`.
@property (nonatomic, nullable) NSError *remoteContentError;

/// The completion block.
@property (nonatomic, copy, nullable) void (^completionBlock)(id <PSPDFRemoteContentObject> remoteObject);

@end

NS_ASSUME_NONNULL_END
