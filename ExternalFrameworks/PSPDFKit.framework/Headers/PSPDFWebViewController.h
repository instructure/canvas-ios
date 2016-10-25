//
//  PSPDFWebViewController.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseViewController.h"
#import "PSPDFExternalURLHandler.h"
#import "PSPDFStyleable.h"

@class PSPDFViewController, PSPDFWebViewController;

NS_ASSUME_NONNULL_BEGIN

/// Delegate for the `PSPDFWebViewController` to customize URL handling.
PSPDF_AVAILABLE_DECL @protocol PSPDFWebViewControllerDelegate <PSPDFExternalURLHandler>

@optional

/// Called when the web controller did start loading.
- (void)webViewControllerDidStartLoad:(PSPDFWebViewController *)controller;

/// Called when the web controller did finish loading.
- (void)webViewControllerDidFinishLoad:(PSPDFWebViewController *)controller;

/// Called when the web controller did fail to load.
- (void)webViewController:(PSPDFWebViewController *)controller didFailLoadWithError:(NSError *)error;

@end

typedef NS_ENUM(NSUInteger, PSPDFWebViewControllerAvailableActions) {
    PSPDFWebViewControllerAvailableActionsNone             = 0,
    PSPDFWebViewControllerAvailableActionsOpenInSafari     = 1 << 0,
    PSPDFWebViewControllerAvailableActionsMailLink         = 1 << 1,
    PSPDFWebViewControllerAvailableActionsCopyLink         = 1 << 2,
    PSPDFWebViewControllerAvailableActionsPrint            = 1 << 3,
    PSPDFWebViewControllerAvailableActionsStopReload       = 1 << 4,
    PSPDFWebViewControllerAvailableActionsBack             = 1 << 5,
    PSPDFWebViewControllerAvailableActionsForward          = 1 << 6,
    PSPDFWebViewControllerAvailableActionsFacebook         = 1 << 7,
    PSPDFWebViewControllerAvailableActionsTwitter          = 1 << 8,
    PSPDFWebViewControllerAvailableActionsMessage          = 1 << 9,

    /// Only offered if Google Chrome is actually installed.
    PSPDFWebViewControllerAvailableActionsOpenInChrome     = 1 << 10,
    PSPDFWebViewControllerAvailableActionsAll              = 0xFFFFFF
} PSPDF_ENUM_AVAILABLE;

PSPDF_EXPORT NSString *const PSPDFWebViewControllerDidStartLoadingNotification;
PSPDF_EXPORT NSString *const PSPDFWebViewControllerDidFinishLoadingNotification;
PSPDF_EXPORT NSString *const PSPDFWebViewControllerDidFailToLoadNotification;

/// Inline Web Browser.
PSPDF_CLASS_AVAILABLE @interface PSPDFWebViewController : PSPDFBaseViewController <PSPDFStyleable, UIWebViewDelegate>

/// Use this to get a `UINavigationController` with a done-button.
+ (UINavigationController *)modalWebViewWithURL:(NSURL *)URL;

/// Creates a new `PSPDFWebViewController` with the specified custom URL request.
- (instancetype)initWithURLRequest:(NSURLRequest *)request;

/// Creates a new `PSPDFWebViewController` with the specified URL.
- (instancetype)initWithURL:(NSURL *)URL;

/// Controls the available actions under the more icon.
/// Defaults to `PSPDFWebViewControllerAvailableActionsAll&~PSPDFWebViewControllerAvailableActionsStopReload` on iPad and
/// `PSPDFWebViewControllerAvailableActionsAll` on iPhone (but with conditionally visible toolbars).
@property (nonatomic) PSPDFWebViewControllerAvailableActions availableActions;

/// Associated delegate, connects to the `PSPDFViewController`.
@property (nonatomic, weak) IBOutlet id<PSPDFWebViewControllerDelegate> delegate;

/// If enabled, shows a progress indicator much like Safari on iOS 7. Defaults to YES.
/// Set this before the view is loaded.
@property (nonatomic) BOOL showProgressIndicator;

/// If set to YES, a custom HTML is loaded when the `UIWebView` encounters an error (like 404).
/// Defaults to YES.
@property (nonatomic) BOOL useCustomErrorPage;

/// If set to yes, we will evaluate `document.title` from the web content and update the title.
/// Defaults to YES.
@property (nonatomic) BOOL shouldUpdateTitleFromWebContent;

/// Uses `WKWebView` when available. Needs to be set before the view is initialized. YES on iOS 8 and higher.
/// This can also be controlled via the global `PSPDFWebKitLegacyModeKey` setting.
@property (nonatomic) BOOL useModernWebKit;

/// The excluded activities.
/// Defaults to `@[UIActivityTypePostToWeibo, UIActivityTypePostToTencentWeibo, UIActivityTypeSaveToCameraRoll]`.
@property (nonatomic, copy) NSArray<NSString *> *excludedActivities;

/// A Boolean value indicating whether the web view suppresses content rendering until it is fully
/// loaded into memory. Defaults to `NO`.
@property (nonatomic) BOOL suppressesIncrementalRendering;

@end

@interface PSPDFWebViewController (SubclassingHooks)

/// Internal webview. Either `UIWebView` or `WKWebView`.
/// `WKWebView` is used on iOS 9, while the classical web view is used on iOS 8.
@property (nonatomic, readonly) UIView *webView;

/// Called on error events if useCustomErrorPage is set.
/// Uses the `StandardError.html` inside `PSPDFKit.bundle`.
- (void)showHTMLWithError:(NSError *)error;

/// This is your chance to modify the settings on the activity controller before it's displayed.
/// @return null if the URL is not set.
@property (nonatomic, readonly, nullable) UIActivityViewController *createDefaultActivityViewController;

/// Go back in history.
- (void)goBack:(nullable id)sender;

/// Go forward in history.
- (void)goForward:(nullable id)sender;

/// Reload page.
- (void)reload:(nullable id)sender;

/// Stop page loading.
- (void)stop:(nullable id)sender;

/// Show activity view controller.
- (void)action:(nullable UIBarButtonItem *)sender;

/// Dismiss PSPDFWebViewController.
- (void)done:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
