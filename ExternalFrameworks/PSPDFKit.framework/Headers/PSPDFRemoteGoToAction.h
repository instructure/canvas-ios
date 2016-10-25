//
//  PSPDFRemoteGoToAction.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFGoToAction.h"

NS_ASSUME_NONNULL_BEGIN

/// Defines the action to go to a specific page in another PDF document.
/// (optionally also to a predefined page)
/// This covers both RemoteGoTo and Launch actions.
PSPDF_CLASS_AVAILABLE @interface PSPDFRemoteGoToAction : PSPDFGoToAction

/// Will create a `PSPDFActionTypeRemoteGoTo`. (Link to another document)
- (instancetype)initWithRelativePath:(nullable NSString *)remotePath pageIndex:(NSUInteger)pageIndex;

/// Path to the remote PDF, if any.
@property (nonatomic, copy, readonly, nullable) NSString *relativePath;

// Also uses `pageIndex` and `namedDestination` from the `PSPDFGoToAction` parent.

@end

NS_ASSUME_NONNULL_END
