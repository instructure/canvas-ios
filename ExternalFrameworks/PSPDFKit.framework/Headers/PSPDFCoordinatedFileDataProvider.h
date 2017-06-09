//
//  PSPDFCoordinatedFileDataProvider.h
//  PSPDFFoundation
//
//  Copyright © 2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFFileDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PSPDFileCoordinationDelegate;

/// A `PSPDFDataProvider` that acts upon a file. All file access is coordinated with file coordination (`NSFileCoordinator`).
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFCoordinatedFileDataProvider : PSPDFFileDataProvider<NSFilePresenter>

/// Receives `NSFilePresenter`-like notifications whent he underlaying file gets updated.
@property (nonatomic, weak) id<PSPDFileCoordinationDelegate> coordinationDelegate;

@end

NS_ASSUME_NONNULL_END
