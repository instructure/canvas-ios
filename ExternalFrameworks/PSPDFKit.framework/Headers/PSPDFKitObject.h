//
//  PSPDFKitObject.h
//  PSPDFKit
//
//  Copyright © 2011-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotationStyleManager.h"
#import "PSPDFApplicationPolicy.h"
#import "PSPDFDatabaseEncryptionProvider.h"
#import "PSPDFEnvironment.h"
#import "PSPDFFileManager.h"
#import "PSPDFLogging.h"
#import "PSPDFMacros.h"
#import "PSPDFVersion.h"
#import <AVFoundation/AVFoundation.h>
#import <Availability.h>

@class PSPDFLibrary, PSPDFCache, PSPDFSignatureManager;
@protocol PSPDFRenderManager;

NS_ASSUME_NONNULL_BEGIN

/// X-Callback URL, see http://x-callback-url.com
/// @note This is used for the Chrome activity in `PSPDFWebViewController`.
/// Example: `PSPDFKit.sharedInstance[PSPDFXCallbackURLStringKey] = @"pspdfcatalog://";`
PSPDF_EXPORT NSString *const PSPDFXCallbackURLStringKey;

/// Custom PSPDFApplicationPolicy instance that can be configured with `setLicenseKey:options:`.
PSPDF_EXPORT NSString *const PSPDFApplicationPolicyKey;

/// Custom PSPDFFileManager instance that can be configured with `setLicenseKey:options:`.
PSPDF_EXPORT NSString *const PSPDFFileManagerKey;

/// Custom coordinated PSPDFFileManager instance that can be configured with `setLicenseKey:options:`.
PSPDF_EXPORT NSString *const PSPDFCoordinatedFileManagerKey;

/**
 Specifies whether coordinated file operations are used by default in `PSPDFDocument`.
 Creates `PSPDFCoordinatedFileDataProvider`s when initializing documents with local URLs.
 Expects a boolean `NSNumber`. Defaults to `@YES`. Set to `@NO` to disable.
 */
PSPDF_EXPORT NSString *const PSPDFFileCoordinationEnabledKey;

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

    /// Enables the UI.
    PSPDFFeatureMaskUI = 1 << 10,

    PSPDFFeatureMaskAll = UINT_MAX
} PSPDF_ENUM_AVAILABLE;

PSPDF_AVAILABLE_DECL @protocol PSPDFSettings<NSObject>

/// Allow generic array access.
- (nullable id)objectForKeyedSubscript:(id)key;

/// Shortcut that returns booleans.
- (BOOL)boolForKey:(NSString *)key;

@end

/**
 PSPDFKit - The Leading PDF Framework for iOS, Android and the Web.
 This is the configuration object for framework-global settings.

 @note The PSPDFKit shared object is a global, thread-safe key/value store.
 Use `setValue:forKey:` and `valueForKey:` or the subscripted variants to set/get properties.

 Subclassing notes:
 In PSPDFKit various classes can be subclassed and registered as subclasses via
 `overrideClass:withClass:` on `PSPDFDocument` (model) and `PSPDFConfiguration` (view/controller).
 See https://pspdfkit.com/guides/ios/current/getting-started/overriding-classes/ for details.
 */
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFKit : NSObject<PSPDFSettings>

/// The shared PSPDFKit configuration instance.
/// @note This is the default instance used in document and pdf controller instances.
@property (atomic, class, readonly) PSPDFKit *sharedInstance;

/// Activate PSPDFKit with your license key from https://customers.pspdfkit.com
+ (void)setLicenseKey:(NSString *)licenseKey;

/// Activate PSPDFKit with your license key from https://customers.pspdfkit.com
/// Variant that allows to set options.
/// These can also later be changed via subscripting access.
+ (void)setLicenseKey:(NSString *)licenseKey options:(nullable NSDictionary<NSString *, id> *)options;

/// Returns the full PSPDFKit product version string
/// (e.g. "PSPDFKit 6.0.0 for iOS (53000)")
@property (atomic, class, readonly) NSString *versionString;

/// Returns just the framework version. (e.g. 6.0.0)
@property (atomic, class, readonly) NSString *versionNumber;

/// Returns the PSPDFKit version date.
@property (atomic, class, readonly) NSDate *compiledAt;

/// The internal build number. Increments with every version.
@property (atomic, class, readonly) NSUInteger buildNumber;

/// Allows to test against specific features. Can test multiple features at once via the bit mask.
+ (BOOL)isFeatureEnabled:(PSPDFFeatureMask)feature;

/// Allow direct dictionary-like access. The `key` must be of type `NSString`.
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;

/// The shared memory/file cache.
@property (nonatomic, readonly) PSPDFCache *cache;

/// The common file manager object.
@property (nonatomic, readonly) id<PSPDFFileManager> fileManager;

/// The PDF render coordinator.
@property (nonatomic, readonly) id<PSPDFRenderManager> renderManager;

/// The annotation style manager.
@property (nonatomic, readonly) id<PSPDFAnnotationStyleManager> styleManager;

/// The shared signature handler for digital signature management.
@property (nonatomic, readonly) PSPDFSignatureManager *signatureManager;

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

/// Various PSPDFKit objects require dependencies.
/// Use this helper to automatically connect them.
/// Will only set known objects that are not already set.
- (NSUInteger)injectDependentProperties:(id)object;

@end

@interface PSPDFKit (ImageLoading)

/**
 Loads images from the PSPDFKit.bundle.

 @note Calls `imageLoadingHandler` if one is set, else falls back to internal loading logic.
*/
+ (nullable UIImage *)imageNamed:(NSString *)name;

/**
 Register a custom block to return custom images.
 If this block is NULL or returns nil, PSPDFKit.bundle will use for the lookup.
 If your custom handler returns no image, the default lookup will be used as well.

 @note Images are cached, so don't return different images for the same `imageName` during an app session.
 This was exposed as `PSPDFSetBundleImageBlock` in earlier versions.
 */
@property (atomic, null_resettable) UIImage *_Nullable (^imageLoadingHandler)(NSString *imageName);

@end

@interface PSPDFKit (Logging)

/**
 Set the global PSPDFKit log level. Defaults to `PSPDFLogLevelMaskInfo|PSPDFLogLevelMaskWarning|PSPDFLogLevelMaskError`.

 @warning Setting this to `PSPDFLogLevelMaskVerbose` will severely slow down your application.
*/
@property (nonatomic) PSPDFLogLevelMask logLevel;

/**
 Allows to set a custom log handler to forward logging to a different system.

 PSPDFKit uses `os_log` or falls back to `NSLog` on older OS versions (iOS 9)
 Setting this to NULL will reset the default behavior.

 @note Usage example:
 ```
 [PSPDFKit.sharedInstance setLogHandler:^(PSPDFLogLevelMask type, const char *tag, NSString *(^message)(void), const char *file, const char *function, NSUInteger line) {
    NSLog(@"PSPDFKit says from %s: %@", function, message());
 }];
 ```
 */
@property (nonatomic, null_resettable) void (^logHandler)(PSPDFLogLevelMask type, const char *_Nullable tag, NSString * (^message)(void), const char *file, const char *function, NSUInteger line);

@end

NS_ASSUME_NONNULL_END
