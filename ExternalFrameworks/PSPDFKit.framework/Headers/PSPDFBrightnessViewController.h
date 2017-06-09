//
//  PSPDFBrightnessViewController.h
//  PSPDFKit
//
//  Copyright © 2012-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAppearanceModeManager.h"
#import "PSPDFBrightnessManager.h"
#import "PSPDFStaticTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// Controller to change the brightness and some related appearance options.
/// In addition to mimicking the system brightness options it also supports additional software dimming and social appearance modes.
/// @note Best presented as popover, configures the `modalPresentationStyle` accordingly at init time.
PSPDF_CLASS_AVAILABLE @interface PSPDFBrightnessViewController : PSPDFStaticTableViewController

/// @section Brightness

/// Brightness manager responsible for brightness control.
@property (nonatomic, nullable) PSPDFBrightnessManager *brightnessManager;

/// @section Appearance

/// The appearance manager responsible for the appearance mode.
/// The appearance UI is not shown if this property is `nil` (default value).
@property (nonatomic, nullable) PSPDFAppearanceModeManager *appearanceModeManager;

/// Possible appearance modes.
/// The appearance UI is not shown if only `PSPDFAppearanceModeDefault` is set (default value).
@property (nonatomic) PSPDFAppearanceMode allowedAppearanceModes;

@end

NS_ASSUME_NONNULL_END
