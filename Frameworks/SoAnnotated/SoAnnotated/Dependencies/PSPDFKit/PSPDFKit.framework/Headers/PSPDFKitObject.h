//
//  PSPDFKitObject.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import <Availability.h>
#import <AVFoundation/AVFoundation.h>
#import "PSPDFFileManager.h"
#import "PSPDFMacros.h"
#import "PSPDFVersion.h"
#import "PSPDFAnnotationStyleManager.h"
#import "PSPDFDatabaseEncryptionProvider.h"
#import "PSPDFApplicationPolicy.h"
#import "PSPDFMacros.h"
#import "PSPDFLogging.h"

@class PSPDFLibrary, PSPDFCache;
@protocol PSPDFRenderManager;

NS_ASSUME_NONNULL_BEGIN

/// X-Callback URL, see http://x-callback-url.com
/// @note This is used for the Chrome activity in `PSPDFWebViewController`.
/// Example: `PSPDFKit.sharedInstance[PSPDFXCallbackURLStringKey] = @"pspdfcatalog://";`
PSPDF_EXPORT NSString *const PSPDFXCallbackURLStringKey;

/// The identifier for the multimedia class, evaluated in `PSPDFMultimediaAnnotationView`.
PSPDF_EXPORT NSString *const PSPDFMultimediaIdentifierKey;

/// Set to `@YES` to disable the use of `WKWebView` when available.
PSPDF_EXPORT NSString *const PSPDFWebKitLegacyModeKey;

/// Declares all possible feature flags in a license.
typedef NS_OPTIONS(NSUInteger, PSPDFFeatureMask) {
    PSPDFFeatureMaskNone = 0,

    /// View PDFs without watermark. Automatically enabled by every valid license key.
    PSPDFFeatureMaskPDFViewer = 1 << 0,

    /// Text Selection. Was included in PSPDFKit Basic.
    PSPDFFeatureMaskTextSelection = 1 << 1,

    /// Enables `PSPDFAESCryptoDataProvider` and the various other crypto related classes.
    /// (`PSPDFCryptoInputStream`, `PSPDFCryptoOutputStream`, `PSPDFAESDecryptor`, `PSPDFAESEncryptor`)
    PSPDFFeatureMaskStrongEncryption = 1 << 2,

    /// Create PDF documents (`PSPDFProcessor` - except flattening).
    PSPDFFeatureMaskPDFCreation = 1 << 3,

    /// Edit/Create annotations.acy)
    PSPDFFeatureMaskAnnotationEditing = 1 << 4,

    /// PDF Forms display/editing.
    PSPDFFeatureMaskAcroForms = 1 << 5,

    /// Use the indexed full-text-search. (`PSPDFLibrary`)
    PSPDFFeatureMaskIndexedFTS = 1 << 6,

    /// Digitally Sign PDF Forms.
    PSPDFFeatureMaskDigitalSignatures = 1 << 7,

    /// Requires PDF files to be signed.
    PSPDFFeatureRequireSignedSource = 1 << 8,

    /// Enables advanced document editing.
    PSPDFFeatureMaskDocumentEditing = 1 << 9,

    PSPDFFeatureMaskAll = UINT_MAX
} PSPDF_ENUM_AVAILABLE;

PSPDF_AVAILABLE_DECL @protocol PSPDFSettings <NSObject>

/// Allow generic array access.
- (nullable id)objectForKeyedSubscript:(id)key;

/// Shortcut that returns booleans.
- (BOOL)boolForKey:(NSString *)key;

@end

/// Configuration object for various framework-global settings.
/// @note The PSPDFKit shared object is a global, thread-safe key/value store.
/// Use `setValue:forKey:` and `valueForKey:` or the subscripted variants to set/get properties.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFKit : NSObject <PSPDFSettings>

/// The shared PSPDFKit configuration instance.
/// @note This is the default instance used in document and pdf controller instances.
+ (instancetype)sharedInstance;

/// Activate PSPDFKit with your license key from https://customers.pspdfkit.com
+ (void)setLicenseKey:(NSString *)licenseKey;

/// Activate PSPDFKit with your license key from https://customers.pspdfkit.com
/// Variant that allows to set options.
/// These can also later be changed via subscripting access.
+ (void)setLicenseKey:(NSString *)licenseKey options:(nullable NSDictionary<NSString *, id> *)options;

/// Returns the PSPDFKit version string.
@property (nonatomic, readonly) NSString *version;

/// Returns the PSPDFKit version date.
@property (nonatomic, readonly) NSDate *compiledAt;

/// Allows to test against specific features. Can test multiple features at once via the bit mask.
+ (BOOL)isFeatureEnabled:(PSPDFFeatureMask)feature;

/// Allow direct dictionary-like access. The `key` must be of type `NSString`.
- (void)setObject:(id)object forKeyedSubscript:(id <NSCopying>)key;

/// The common file manager object.
@property (nonatomic, readonly) id<PSPDFFileManager> fileManager;

/// The shared memory/file cache.
@property (nonatomic, readonly) PSPDFCache *cache;

/// The PDF render coordinator.
@property (nonatomic, readonly) id<PSPDFRenderManager> renderManager;

/// The annotation style manager.
@property (nonatomic, readonly) id<PSPDFAnnotationStyleManager> styleManager;

/// Controls various security-related aspects and allows to enable/disable features based on the security settings.
@property (nonatomic, readonly) id<PSPDFApplicationPolicy> policy;

/// The default library. You can override this property to use a custom `PSPDFLibrary` as the default
/// library. It is recommended that you do this early in your application launch. Defaults to an
/// unencrypted library by default or to `nil` if the FTS feature is not enabled in the license.
@property (atomic, nullable) PSPDFLibrary *library;

/// An encryption provider for databases. Defaults to `nil`. You must set this property
/// before using any database encryption features. See `PSPDFDatabaseEncryptionProvider` for more
/// information on how to implement this.
@property (atomic, nullable) id<PSPDFDatabaseEncryptionProvider> databaseEncryptionProvider;

/// Various PSPDFKit objects require dependencies. Use this helper to automatically connect them.
/// Will only set known objects that are not already set.
- (NSUInteger)injectDependentProperties:(id)object;

@end

@interface PSPDFKit (Logging)

/// Set the global PSPDFKit log level. Defaults to `PSPDFLogLevelMaskError|PSPDFLogLevelMaskWarning`.
/// @warning Setting this to `PSPDFLogLevelMaskVerbse` will severely slow down your application.
@property (nonatomic) PSPDFLogLevelMask logLevel;

/// Allows to set a custom log handler to forward logging to a different system.
/// By default, we use NSLog for logging. Setting this to NULL will reset the default behavior.
/// Usage example:
/// `[PSPDFKit.sharedInstance setLogHandler:^(NSString *(^message)(void), PSPDFLogLevelMask level, const char *file, const char *function, NSUInteger line) {`
///   `NSLog(@"PSPDFKit says from %s: %@", function, message());`
/// `}];`
@property (nonatomic, null_resettable) void (^logHandler)(NSString *(^message)(void), PSPDFLogLevelMask level, const char *file, const char *function, NSUInteger line);

@end

NS_ASSUME_NONNULL_END
