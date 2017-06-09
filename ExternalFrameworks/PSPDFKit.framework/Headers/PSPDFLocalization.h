//
//  PSPDFLocalization.h
//  PSPDFKit
//
//  Copyright © 2012-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Localizes strings. Will first look up the string in the PSPDFKit.bundle
PSPDF_EXPORT NSString *PSPDFLocalize(NSString *_Nullable stringToken) NS_FORMAT_ARGUMENT(1);

/// Localizes strings with a list of arguments to substitute into `stringToken`.
PSPDF_EXPORT NSString *PSPDFLocalizeFormatted(NSString *stringToken, ...) NS_FORMAT_FUNCTION(1, 2);

/**
 Allows to set a custom dictionary that contains dictionaries with language locales.
 Will override localization found in the bundle, if a value is found.
 Falls back to "en" if localization key is not found in dictionary.
 Set on the main thread.
 */
PSPDF_EXPORT void PSPDFSetLocalizationDictionary(NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *_Nullable localizationDict);

/**
 Register a custom block that handles translation.
 If this block is NULL or returns nil, the PSPDFKit.bundle + localizationDict will be used.
 */
PSPDF_EXPORT void PSPDFSetLocalizationBlock(NSString *__nullable (^localizationBlock)(NSString *_Nullable stringToLocalize));

/// Extends `NSObject` with an accessibility helper.
@interface NSObject (PSPDFLocalizedAccessibility)

/**
 This property sets the `accessibilityIdentifier` with the value set, and then sets
 `accessibilityLabel` with the localized text.

 If this property is queried, the `accessibilityIdentifier` is returned.

 @note If the object does not comply to the `UIAccessibilityIdentification` protocol,
 we fall back to only setting the label and also returning the label.
 */
@property (nullable, nonatomic, copy) NSString *pspdf_accessibility;

@end

NS_ASSUME_NONNULL_END
