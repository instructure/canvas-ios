//
//  PSPDFAppearanceModeManager.h
//  PSPDFKit
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

@class PSPDFAppearanceModeManager, PSPDFConfigurationBuilder;

typedef NS_OPTIONS(NSUInteger, PSPDFAppearanceMode) {
    /// Normal application appearance.
    PSPDFAppearanceModeDefault = 0,
    /// Renders content with a sepia tone.
    PSPDFAppearanceModeSepia = 1 << 0,
    /// Inverts page content and applies a dark application theme.
    PSPDFAppearanceModeNight = 1 << 1,
    /// All options.
    PSPDFAppearanceModeAll = PSPDFAppearanceModeDefault | PSPDFAppearanceModeSepia | PSPDFAppearanceModeNight
};

NS_ASSUME_NONNULL_BEGIN

/// Notification sent out after `appearanceMode` is changed.
PSPDF_EXPORT NSString *const PSPDFAppearanceModeChangedNotification;

/// Notification `userInfo` dictionary key. Holds a `BOOL` `NSNumber` which is `YES`
/// when an animated mode change was requested.
PSPDF_EXPORT NSString *const PSPDFAppearanceModeChangedAnimatedKey;

PSPDF_AVAILABLE_DECL @protocol PSPDFAppearanceModeManagerDelegate <NSObject>

@optional

/// Provides the document render options for the specified mode.
/// @note Overrides the default behavior, if implemented.
- (NSDictionary<NSString *, id> *)appearanceManager:(PSPDFAppearanceModeManager *)manager renderOptionsForMode:(PSPDFAppearanceMode)mode;

/// Update any UIAppearance changes for the selected mode.
/// @note Overrides the default behavior, if implemented.
- (void)appearanceManager:(PSPDFAppearanceModeManager *)manager applyAppearanceSettingsForMode:(PSPDFAppearanceMode)mode;

/// Update `builder` with any settings specific to the provided `mode`.
/// @note Overrides the default behavior, if implemented.
- (void)appearanceManager:(PSPDFAppearanceModeManager *)manager updateConfiguration:(PSPDFConfigurationBuilder *)builder forMode:(PSPDFAppearanceMode)mode;

@end

PSPDF_CLASS_AVAILABLE @interface PSPDFAppearanceModeManager : NSObject

/// The currently selected application appearance mode. Defaults to `PSPDFAppearanceModeDefault`.
@property (nonatomic) PSPDFAppearanceMode appearanceMode;

/// Sets the appearance mode. Fades any theme changes if animated is set to `YES`.
- (void)setAppearanceMode:(PSPDFAppearanceMode)appearanceMode animated:(BOOL)animated;

/// The appearance delegate. Can be used to customize the default behaviors for each mode.
@property (nonatomic, weak) id<PSPDFAppearanceModeManagerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
