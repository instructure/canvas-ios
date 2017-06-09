//
//  PSPDFSettingsViewController.h
//  PSPDFKit
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFStaticTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, PSPDFSettingsOptions) {
    PSPDFSettingsOptionNone = 0,
    PSPDFSettingsOptionScrollDirection = 1 << 0,
    PSPDFSettingsOptionPageTransition = 1 << 1,
    PSPDFSettingsOptionAppearance = 1 << 2,
    PSPDFSettingsOptionBrightness = 1 << 3,
    PSPDFSettingsOptionPageMode = 1 << 4,
    PSPDFSettingsOptionDefault = PSPDFSettingsOptionScrollDirection | PSPDFSettingsOptionPageTransition | PSPDFSettingsOptionAppearance | PSPDFSettingsOptionBrightness,
    PSPDFSettingsOptionAll = NSUIntegerMax,
} PSPDF_ENUM_AVAILABLE;

@class PSPDFViewController;

/// Controller to change some key UX settings.
/// Configurable via `PSPDFConfiguration.settingsOptions` property. Use `PSPDFViewController.settingsButtonItem` to add it to controller's navigation item.
PSPDF_CLASS_AVAILABLE @interface PSPDFSettingsViewController : PSPDFStaticTableViewController

/// Reference to the controller which will be configured with `PSPDFSettingsViewController`.
@property (nonatomic, weak) PSPDFViewController *pdfViewController;

@end

NS_ASSUME_NONNULL_END
