//
//  PSPDFLocalization.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import "PSPDFEnvironment.h"
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Localizes strings. Will first look up the string in the PSPDFKit.bundle
PSPDF_EXPORT NSString *PSPDFLocalize(NSString *_Nullable stringToken) NS_FORMAT_ARGUMENT(1);

/// Localizes strings with a list of arguments to substitute into `stringToken`.
PSPDF_EXPORT NSString *PSPDFLocalizeFormatted(NSString *stringToken, ...) NS_FORMAT_FUNCTION(1,2);

/// Allows to set a custom dictionary that contains dictionaries with language locales.
/// Will override localization found in the bundle, if a value is found.
/// Falls back to "en" if localization key is not found in dictionary.
/// Set on the main thread.
PSPDF_EXPORT void PSPDFSetLocalizationDictionary(NSDictionary<NSString *, NSDictionary<NSString *, NSString *>*> *_Nullable localizationDict);

/// Register a custom block that handles translation.
/// If this block is NULL or returns nil, the PSPDFKit.bundle + localizationDict will be used.
PSPDF_EXPORT void PSPDFSetLocalizationBlock(NSString *__nullable (^localizationBlock)(NSString *_Nullable stringToLocalize));

/// Will load an image from the bundle. Will auto-manage legacy images and bundle directory.
PSPDF_EXPORT UIImage *_Nullable PSPDFBundleImage(NSString *_Nullable imageName);

/// Register a custom block to return custom images.
/// If this block is NULL or returns nil, PSPDFKit.bundle will use for the lookup.
/// @note Images are cached, so don't return different images for the same `imageName` during an app session.
PSPDF_EXPORT void PSPDFSetBundleImageBlock(UIImage *_Nullable (^_Nullable imageBlock)(NSString *_Nullable imageName));

NS_ASSUME_NONNULL_END
